import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/controllers/auth_controller.dart';
import 'auth_state.dart';

/// Provides feature gate checks based on auth state.
final featureGateProvider = Provider<FeatureGate>((ref) {
  final authState = ref.watch(authControllerProvider);
  return FeatureGate(authState);
});

/// Gates features based on authentication status.
///
/// Anonymous users can use core features offline.
/// Authenticated users get additional collaboration features.
class FeatureGate {
  FeatureGate(this._authState);

  final AppAuthState _authState;

  // ===========================================================================
  // Authenticated-only features
  // ===========================================================================

  /// Can join group forays created by others.
  bool get canJoinForay => _authState.isAuthenticated;

  /// Can create group forays with join codes.
  bool get canCreateGroupForay => _authState.isAuthenticated;

  /// Can share observations and forays.
  bool get canShare => _authState.isAuthenticated;

  /// Can sync data to the cloud.
  bool get canSync => _authState.isAuthenticated;

  /// Can add comments on observations.
  bool get canComment => _authState.isAuthenticated;

  /// Can vote on identifications.
  bool get canVote => _authState.isAuthenticated;

  /// Can add identifications to others' observations.
  bool get canIdentify => _authState.isAuthenticated;

  /// Can participate in real-time collaboration.
  bool get canCollaborate => _authState.isAuthenticated;

  // ===========================================================================
  // Always available features
  // ===========================================================================

  /// Can create personal/solo forays.
  bool get canCreateSoloForay => true;

  /// Can add observations to own forays.
  bool get canAddObservation => true;

  /// Can use compass navigation.
  bool get canNavigate => true;

  /// Can view maps.
  bool get canViewMaps => true;

  /// Can take photos.
  bool get canTakePhotos => true;

  /// Can edit own observations.
  bool get canEditOwn => true;

  /// Can use the app offline.
  bool get canUseOffline => true;

  // ===========================================================================
  // Helper Methods
  // ===========================================================================

  /// Get restriction message for a feature.
  ///
  /// Returns null if feature is allowed.
  String? getRestrictionMessage(String feature) {
    if (_authState.isAuthenticated) return null;

    return 'Sign in to $feature';
  }

  /// Check if any collaboration feature is available.
  bool get hasCollaborationFeatures => _authState.isAuthenticated;

  /// Get a message explaining what signing in would enable.
  String get signInBenefitsMessage {
    return 'Sign in to sync your observations, '
        'join group forays, and collaborate with other mycologists.';
  }
}
