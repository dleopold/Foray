import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../database/database.dart';
import '../../../../services/supabase_service.dart';
import '../../domain/auth_state.dart';

/// Provides the authentication controller.
final authControllerProvider =
    StateNotifierProvider<AuthController, AppAuthState>((ref) {
  // supabaseAuthProvider returns null when Supabase is not available (web/unconfigured)
  final auth = ref.watch(supabaseAuthProvider);
  final db = ref.watch(databaseProvider);
  return AuthController(auth, db);
});

/// Manages authentication state.
///
/// Supports both anonymous (local-only) mode and Supabase authentication.
/// Anonymous users can be upgraded to authenticated accounts while
/// preserving their local data.
class AuthController extends StateNotifier<AppAuthState> {
  AuthController(this._auth, this._db) : super(const AppAuthState()) {
    _init();
  }

  final GoTrueClient? _auth;
  final AppDatabase _db;
  StreamSubscription<AuthState>? _authSubscription;
  final _uuid = const Uuid();

  /// Initialize auth state.
  Future<void> _init() async {
    state = state.copyWith(status: AppAuthStatus.loading);

    try {
      // Listen to Supabase auth changes (if configured)
      if (_auth != null) {
        _authSubscription = _auth.onAuthStateChange.listen((data) {
          _handleAuthChange(data.event, data.session);
        });
      }

      // Check for existing local user
      final localUser = await _db.usersDao.getCurrentUser();

      if (localUser != null) {
        if (localUser.isAnonymous) {
          state = AppAuthState(
            status: AppAuthStatus.anonymous,
            user: localUser,
          );
        } else {
          // Verify Supabase session is still valid
          final session = _auth?.currentSession;
          if (session != null) {
            state = AppAuthState(
              status: AppAuthStatus.authenticated,
              user: localUser,
            );
          } else {
            // Session expired - still allow local access but mark as anonymous
            state = AppAuthState(
              status: AppAuthStatus.anonymous,
              user: localUser,
            );
          }
        }
      } else {
        // First launch - create anonymous user
        await _createAnonymousUser();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Auth initialization error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // On error, create anonymous user as fallback
      try {
        await _createAnonymousUser();
      } catch (e2) {
        if (kDebugMode) {
          debugPrint('Failed to create anonymous user: $e2');
        }
        // Last resort - set to anonymous without user
        state = const AppAuthState(status: AppAuthStatus.anonymous);
      }
    }
  }

  /// Create a new anonymous user.
  Future<void> _createAnonymousUser() async {
    final deviceId = _uuid.v4();
    final userId = _uuid.v4();

    final user = await _db.usersDao.createAnonymousUser(
      id: userId,
      deviceId: deviceId,
      displayName: 'Guest User',
    );

    state = AppAuthState(
      status: AppAuthStatus.anonymous,
      user: user,
    );
  }

  /// Handle Supabase auth state changes.
  void _handleAuthChange(AuthChangeEvent event, Session? session) async {
    if (kDebugMode) {
      debugPrint('Auth state change: $event, hasSession: ${session != null}');
    }
    if (event == AuthChangeEvent.signedIn && session != null) {
      await _handleSignIn(session);
    } else if (event == AuthChangeEvent.signedOut) {
      await _handleSignOut();
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      // Session refreshed, no action needed
      if (kDebugMode) {
        debugPrint('Auth token refreshed');
      }
    } else if (event == AuthChangeEvent.userUpdated && session != null) {
      // User profile updated remotely
      await _handleUserUpdated(session);
    }
  }

  /// Handle user profile update from Supabase.
  Future<void> _handleUserUpdated(Session session) async {
    final supabaseUser = session.user;
    final localUser = state.user;

    if (localUser != null && !localUser.isAnonymous) {
      // Update local user with remote changes
      await _db.usersDao.updateUser(
        localUser.id,
        UsersCompanion(
          displayName: supabaseUser.userMetadata?['name'] != null
              ? Value(supabaseUser.userMetadata!['name'] as String)
              : const Value.absent(),
          avatarUrl: supabaseUser.userMetadata?['avatar_url'] != null
              ? Value(supabaseUser.userMetadata!['avatar_url'] as String)
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updatedUser = await _db.usersDao.getCurrentUser();
      state = state.copyWith(user: updatedUser);

      if (kDebugMode) {
        debugPrint('User profile updated from remote');
      }
    }
  }

  /// Check if the current session is still valid.
  ///
  /// Call this on app resume to handle session expiration.
  Future<void> checkSessionValidity() async {
    if (_auth == null || !state.isAuthenticated) return;

    final session = _auth.currentSession;
    if (session == null) {
      // Session expired
      if (kDebugMode) {
        debugPrint('Session expired, downgrading to anonymous');
      }
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: 'Your session has expired. Please sign in again.',
      );
    } else if (session.isExpired) {
      // Try to refresh
      try {
        await _auth.refreshSession();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to refresh session: $e');
        }
        state = state.copyWith(
          status: AppAuthStatus.anonymous,
          errorMessage: 'Your session has expired. Please sign in again.',
        );
      }
    }
  }

  /// Handle successful sign in.
  Future<void> _handleSignIn(Session session) async {
    if (kDebugMode) {
      debugPrint('_handleSignIn called with user: ${session.user.email}');
    }
    final supabaseUser = session.user;
    final localUser = state.user;

    if (localUser != null && localUser.isAnonymous) {
      // Upgrade anonymous user to authenticated
      await _db.usersDao.upgradeToAuthenticated(
        localId: localUser.id,
        remoteId: supabaseUser.id,
        email: supabaseUser.email!,
        displayName: supabaseUser.userMetadata?['name'] as String?,
        avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      );

      final updatedUser = await _db.usersDao.getCurrentUser();
      state = AppAuthState(
        status: AppAuthStatus.authenticated,
        user: updatedUser,
      );
    } else {
      // New device login - check if user exists
      var existingUser =
          await _db.usersDao.getUserByRemoteId(supabaseUser.id);

      if (existingUser == null) {
        // Create new local user linked to remote
        existingUser = await _db.usersDao.createAnonymousUser(
          id: _uuid.v4(),
          deviceId: _uuid.v4(),
          displayName:
              supabaseUser.userMetadata?['name'] as String? ?? 'User',
        );
        await _db.usersDao.upgradeToAuthenticated(
          localId: existingUser.id,
          remoteId: supabaseUser.id,
          email: supabaseUser.email!,
          displayName: supabaseUser.userMetadata?['name'] as String?,
          avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
        );
        existingUser = await _db.usersDao.getCurrentUser();
      } else {
        // Existing user on new device - set as current
        await _db.usersDao.setCurrentUser(existingUser.id);
      }

      state = AppAuthState(
        status: AppAuthStatus.authenticated,
        user: existingUser,
      );
    }
  }

  /// Handle sign out.
  Future<void> _handleSignOut() async {
    // Keep local data, just mark as anonymous
    state = state.copyWith(status: AppAuthStatus.anonymous);
  }

  // ===========================================================================
  // Public Methods
  // ===========================================================================

  /// Sign in with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    if (_auth == null) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Running in offline mode.',
      );
      return;
    }

    state = state.copyWith(status: AppAuthStatus.loading, clearError: true);

    try {
      if (kDebugMode) {
        debugPrint('Attempting sign in for: $email');
      }
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        debugPrint('Sign in response: hasSession=${response.session != null}, hasUser=${response.user != null}');
      }
      // State will be updated by auth listener
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Sign up with email and password.
  /// Returns true if email confirmation is required.
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    if (_auth == null) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Running in offline mode.',
      );
      return false;
    }

    state = state.copyWith(status: AppAuthStatus.loading, clearError: true);

    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': displayName},
      );

      // If session is null but user exists, email confirmation is required
      if (response.session == null && response.user != null) {
        state = state.copyWith(status: AppAuthStatus.anonymous);
        return true; // Email confirmation needed
      }

      // State will be updated by auth listener if session exists
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Sign in with Google OAuth.
  Future<void> signInWithGoogle() async {
    if (_auth == null) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Running in offline mode.',
      );
      return;
    }

    state = state.copyWith(status: AppAuthStatus.loading, clearError: true);

    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.oauthRedirectUrl,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Sign in with Apple OAuth.
  Future<void> signInWithApple() async {
    if (_auth == null) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Running in offline mode.',
      );
      return;
    }

    state = state.copyWith(status: AppAuthStatus.loading, clearError: true);

    try {
      await _auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: SupabaseConfig.oauthRedirectUrl,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppAuthStatus.anonymous,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    state = state.copyWith(status: AppAuthStatus.loading, clearError: true);

    try {
      if (_auth != null) {
        await _auth.signOut();
      }
      state = state.copyWith(status: AppAuthStatus.anonymous);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to sign out',
      );
    }
  }

  /// Request password reset email.
  Future<void> resetPassword(String email) async {
    if (_auth == null) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Running in offline mode.',
      );
      return;
    }

    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send password reset email',
      );
    }
  }

  /// Update user profile.
  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final user = state.user;
    if (user == null) return;

    await _db.usersDao.updateUser(
      user.id,
      UsersCompanion(
        displayName:
            displayName != null ? Value(displayName) : const Value.absent(),
        avatarUrl:
            avatarUrl != null ? Value(avatarUrl) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final updatedUser = await _db.usersDao.getCurrentUser();
    state = state.copyWith(user: updatedUser);
  }

  /// Clear any error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
