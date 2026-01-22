# Specification: Authentication System

**Phase:** 3  
**Estimated Duration:** 4-5 days  
**Dependencies:** Phase 2 complete  
**Patterns & Pitfalls:** See `PATTERNS_AND_PITFALLS.md` — [Supabase Integration](#4-supabase-integration), [GoRouter Pitfalls](#6-gorouter-pitfalls)

---

## 1. Supabase Project Setup

### 1.1 Supabase Configuration

1. Create a new Supabase project at https://supabase.com
2. Note your project URL and anon key
3. Enable the following auth providers:
   - Email/Password
   - Google OAuth
   - Apple OAuth (for iOS)

### 1.2 Environment Configuration

Create `lib/core/config/supabase_config.dart`:

```dart
abstract class SupabaseConfig {
  // These should come from environment variables in production
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
```

For local development, create `.env` file (add to `.gitignore`):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 1.3 Supabase Initialization

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foray/app.dart';
import 'package:foray/core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(
    const ProviderScope(
      child: ForayApp(),
    ),
  );
}
```

### 1.4 Supabase Client Provider

```dart
// lib/services/supabase_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseClientProvider).auth;
});
```

---

## 2. Auth State Management

### 2.1 Auth State Model

```dart
// lib/features/auth/domain/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:foray/database/database.dart';

enum AuthStatus {
  initial,
  anonymous,
  authenticated,
  loading,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAnonymous => status == AuthStatus.anonymous;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
```

### 2.2 Auth Controller

```dart
// lib/features/auth/presentation/controllers/auth_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/domain/auth_state.dart';
import 'package:foray/services/supabase_service.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(supabaseAuthProvider),
    ref.watch(databaseProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._auth, this._db) : super(const AuthState()) {
    _init();
  }

  final GoTrueClient _auth;
  final AppDatabase _db;
  StreamSubscription<AuthState>? _authSubscription;
  final _uuid = const Uuid();

  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    // Listen to Supabase auth changes
    _auth.onAuthStateChange.listen((data) {
      _handleAuthChange(data.event, data.session);
    });
    
    // Check for existing local user
    final localUser = await _db.usersDao.getCurrentUser();
    
    if (localUser != null) {
      if (localUser.isAnonymous) {
        state = AuthState(
          status: AuthStatus.anonymous,
          user: localUser,
        );
      } else {
        // Verify Supabase session is still valid
        final session = _auth.currentSession;
        if (session != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: localUser,
          );
        } else {
          // Session expired, downgrade to anonymous or prompt re-login
          state = AuthState(
            status: AuthStatus.anonymous,
            user: localUser,
          );
        }
      }
    } else {
      // First launch - create anonymous user
      await _createAnonymousUser();
    }
  }

  Future<void> _createAnonymousUser() async {
    final deviceId = _uuid.v4();
    final userId = _uuid.v4();
    
    final user = await _db.usersDao.createAnonymousUser(
      id: userId,
      deviceId: deviceId,
      displayName: 'Guest User',
    );
    
    state = AuthState(
      status: AuthStatus.anonymous,
      user: user,
    );
  }

  void _handleAuthChange(AuthChangeEvent event, Session? session) async {
    if (event == AuthChangeEvent.signedIn && session != null) {
      await _handleSignIn(session);
    } else if (event == AuthChangeEvent.signedOut) {
      await _handleSignOut();
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      // Session refreshed, no action needed
    }
  }

  Future<void> _handleSignIn(Session session) async {
    final supabaseUser = session.user;
    final localUser = state.user;
    
    if (localUser != null && localUser.isAnonymous) {
      // Upgrade anonymous user to authenticated
      await _db.usersDao.upgradeToAuthenticated(
        localId: localUser.id,
        remoteId: supabaseUser.id,
        email: supabaseUser.email!,
        displayName: supabaseUser.userMetadata?['name'],
        avatarUrl: supabaseUser.userMetadata?['avatar_url'],
      );
      
      final updatedUser = await _db.usersDao.getCurrentUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: updatedUser,
      );
    } else {
      // New device login - check if user exists remotely
      var existingUser = await _db.usersDao.getUserByRemoteId(supabaseUser.id);
      
      if (existingUser == null) {
        // Create new local user linked to remote
        existingUser = await _db.usersDao.createAnonymousUser(
          id: _uuid.v4(),
          deviceId: _uuid.v4(),
          displayName: supabaseUser.userMetadata?['name'] ?? 'User',
        );
        await _db.usersDao.upgradeToAuthenticated(
          localId: existingUser.id,
          remoteId: supabaseUser.id,
          email: supabaseUser.email!,
          displayName: supabaseUser.userMetadata?['name'],
          avatarUrl: supabaseUser.userMetadata?['avatar_url'],
        );
        existingUser = await _db.usersDao.getCurrentUser();
      }
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: existingUser,
      );
    }
  }

  Future<void> _handleSignOut() async {
    // Keep local data, just mark as anonymous
    state = state.copyWith(status: AuthStatus.anonymous);
  }

  // Public methods
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      // State will be updated by auth listener
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.anonymous,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _auth.signUp(
        email: email,
        password: password,
        data: {'name': displayName},
      );
      // State will be updated by auth listener
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.anonymous,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.foray.app://login-callback',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.anonymous,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.foray.app://login-callback',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.anonymous,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _auth.signOut();
      state = state.copyWith(status: AuthStatus.anonymous);
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final user = state.user;
    if (user == null) return;
    
    await _db.usersDao.updateUser(
      user.id,
      UsersCompanion(
        displayName: displayName != null ? Value(displayName) : const Value.absent(),
        avatarUrl: avatarUrl != null ? Value(avatarUrl) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    
    final updatedUser = await _db.usersDao.getCurrentUser();
    state = state.copyWith(user: updatedUser);
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
```

---

## 3. Anonymous Mode

### 3.1 Anonymous User Features

Anonymous users can:
- Create solo forays
- Add observations to solo forays
- Use compass navigation
- View their own maps
- Full offline functionality

Anonymous users cannot:
- Join group forays
- Share observations
- Sync to cloud
- Access from other devices

### 3.2 Feature Gate Provider

```dart
// lib/features/auth/domain/feature_gate.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import '../presentation/controllers/auth_controller.dart';

final featureGateProvider = Provider<FeatureGate>((ref) {
  final authState = ref.watch(authControllerProvider);
  return FeatureGate(authState);
});

class FeatureGate {
  FeatureGate(this._authState);

  final AuthState _authState;

  bool get canJoinForay => _authState.isAuthenticated;
  bool get canCreateGroupForay => _authState.isAuthenticated;
  bool get canShare => _authState.isAuthenticated;
  bool get canSync => _authState.isAuthenticated;
  bool get canComment => _authState.isAuthenticated;
  bool get canVote => _authState.isAuthenticated;
  
  // Always available
  bool get canCreateSoloForay => true;
  bool get canAddObservation => true;
  bool get canNavigate => true;
  bool get canViewMaps => true;

  String? getRestrictionMessage(String feature) {
    if (_authState.isAuthenticated) return null;
    
    return 'Sign in to $feature';
  }
}
```

### 3.3 Upgrade Prompt Widget

```dart
// lib/features/auth/presentation/widgets/upgrade_prompt.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/routing/routes.dart';

class UpgradePrompt extends StatelessWidget {
  const UpgradePrompt({
    super.key,
    required this.message,
    this.feature,
  });

  final String message;
  final String? feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.login),
                child: const Text('Sign In'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Registration Flow

### 4.1 Registration Screen

```dart
// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/buttons/foray_button.dart';
import 'package:foray/core/widgets/inputs/foray_text_field.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/auth/domain/auth_state.dart';
import 'package:foray/routing/routes.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                
                // Logo or illustration
                Icon(
                  Icons.eco,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                Text(
                  'Join Foray',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create an account to sync your observations and join group forays.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Display name
                ForayTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  hint: 'How others will see you',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a display name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Email
                ForayTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Password
                ForayTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 8 characters',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Confirm password
                ForayTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Submit button
                ForayButton(
                  onPressed: _submit,
                  label: 'Create Account',
                  isLoading: authState.isLoading,
                  fullWidth: true,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'or continue with',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Social login buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata), // Replace with Google icon
                        label: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authControllerProvider.notifier).signInWithApple(),
                        icon: const Icon(Icons.apple),
                        label: const Text('Apple'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _displayNameController.text.trim(),
      );
    }
  }
}
```

---

## 5. Login Flow

### 5.1 Login Screen

```dart
// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/buttons/foray_button.dart';
import 'package:foray/core/widgets/inputs/foray_text_field.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/auth/domain/auth_state.dart';
import 'package:foray/routing/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                
                // Logo
                Icon(
                  Icons.eco,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Email
                ForayTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Password
                ForayTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Submit button
                ForayButton(
                  onPressed: _submit,
                  label: 'Sign In',
                  isLoading: authState.isLoading,
                  fullWidth: true,
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'or continue with',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Social login buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authControllerProvider.notifier).signInWithApple(),
                        icon: const Icon(Icons.apple),
                        label: const Text('Apple'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
                
                // Continue as guest
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'your@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier)
                  .resetPassword(emailController.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Auth UI Integration

### 6.1 Route Guard

```dart
// lib/routing/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/auth/domain/auth_state.dart';
import 'routes.dart';

// Routes that require authentication
const _authRequiredRoutes = [
  AppRoutes.createForay, // Group foray only
  AppRoutes.joinForay,
];

String? authGuard(BuildContext context, GoRouterState state, WidgetRef ref) {
  final authState = ref.read(authControllerProvider);
  final isAuthRoute = state.uri.path == AppRoutes.login || 
                      state.uri.path == AppRoutes.register;
  
  // If authenticated and trying to access auth routes, redirect to home
  if (authState.isAuthenticated && isAuthRoute) {
    return AppRoutes.home;
  }
  
  // If not authenticated and trying to access protected routes
  if (!authState.isAuthenticated && _authRequiredRoutes.contains(state.uri.path)) {
    return AppRoutes.login;
  }
  
  return null; // No redirect
}
```

### 6.2 Auth-Aware App Bar

```dart
// lib/core/widgets/auth_app_bar_action.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/core/widgets/cards/foray_avatar.dart';
import 'package:foray/routing/routes.dart';

class AuthAppBarAction extends ConsumerWidget {
  const AuthAppBarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    if (authState.isAuthenticated) {
      return GestureDetector(
        onTap: () => context.push(AppRoutes.settings),
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ForayAvatar(
            imageUrl: authState.user?.avatarUrl,
            name: authState.user?.displayName ?? 'User',
            size: 32,
          ),
        ),
      );
    } else {
      return TextButton(
        onPressed: () => context.push(AppRoutes.login),
        child: const Text('Sign In'),
      );
    }
  }
}
```

---

## Acceptance Criteria

Phase 3 is complete when:

1. [ ] Supabase project configured with auth providers
2. [ ] Anonymous user created on first launch
3. [ ] Email/password registration works
4. [ ] Email/password login works
5. [ ] Social login (Google, Apple) works
6. [ ] Anonymous data migrates on account creation
7. [ ] Session persists across app restarts
8. [ ] Logout works correctly
9. [ ] Password reset email sends
10. [ ] Route guards protect authenticated routes
11. [ ] Feature gates block unauthenticated actions appropriately
