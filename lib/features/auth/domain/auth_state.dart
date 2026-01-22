import 'package:equatable/equatable.dart';

import '../../../database/database.dart';

/// Authentication status.
enum AppAuthStatus {
  /// Initial state before checking auth.
  initial,

  /// User is anonymous (local-only mode).
  anonymous,

  /// User is authenticated with Supabase.
  authenticated,

  /// Auth operation in progress.
  loading,

  /// Auth error occurred.
  error,
}

/// Represents the current authentication state.
///
/// Named `AppAuthState` to avoid conflict with Supabase's `AuthState`.
/// This class is immutable and uses Equatable for value comparison.
class AppAuthState extends Equatable {
  const AppAuthState({
    this.status = AppAuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Current authentication status.
  final AppAuthStatus status;

  /// Current user from local database (if any).
  final User? user;

  /// Error message from last failed operation.
  final String? errorMessage;

  /// Whether user is fully authenticated with Supabase.
  bool get isAuthenticated => status == AppAuthStatus.authenticated;

  /// Whether user is in anonymous/local-only mode.
  bool get isAnonymous => status == AppAuthStatus.anonymous;

  /// Whether an auth operation is in progress.
  bool get isLoading => status == AppAuthStatus.loading;

  /// Whether there's an error.
  bool get hasError => status == AppAuthStatus.error || errorMessage != null;

  /// Whether user can access features (either authenticated or anonymous).
  bool get isReady =>
      status == AppAuthStatus.authenticated || status == AppAuthStatus.anonymous;

  /// Create a copy with updated fields.
  AppAuthState copyWith({
    AppAuthStatus? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
