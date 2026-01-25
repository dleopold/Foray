import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/foray_button.dart';
import '../../../../core/widgets/inputs/foray_text_field.dart';
import '../../../../routing/routes.dart';
import '../../domain/auth_state.dart';
import '../controllers/auth_controller.dart';

// Use aliased import to avoid conflict with Supabase's AuthState
typedef AuthState = AppAuthState;
typedef AuthStatus = AppAuthStatus;

/// Screen for creating a new account.
///
/// Supports email/password and social auth (Google, Apple).
/// Anonymous users who register will have their local data
/// preserved and linked to their new account.
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
    final theme = Theme.of(context);

    // Listen for auth state changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        // Successfully registered - navigate to home
        context.go(AppRoutes.home);
      }
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        // Clear the error after showing
        ref.read(authControllerProvider.notifier).clearError();
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

                // Logo
                Icon(
                  Icons.eco,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Join Foray',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create an account to sync your observations '
                  'and join group forays.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
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
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a display name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
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
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!_isValidEmail(value)) {
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
                  suffixIcon:
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
                  onPressed: authState.isLoading ? null : _submit,
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'or continue with',
                        style: theme.textTheme.bodySmall,
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
                            : () => ref
                                .read(authControllerProvider.notifier)
                                .signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm + 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref
                                .read(authControllerProvider.notifier)
                                .signInWithApple(),
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text('Apple'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm + 4,
                          ),
                        ),
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
                      style: theme.textTheme.bodyMedium,
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final needsConfirmation =
          await ref.read(authControllerProvider.notifier).signUpWithEmail(
                _emailController.text.trim(),
                _passwordController.text,
                _displayNameController.text.trim(),
              );

      if (needsConfirmation && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Check Your Email'),
            content: Text(
              'We sent a confirmation link to ${_emailController.text.trim()}. '
              'Please check your email and click the link to complete registration.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.login);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
