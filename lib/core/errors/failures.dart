abstract class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network error. Please check your connection.',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error.']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Could not get location.']);
}

class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Camera error.']);
}

class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Sync failed. Will retry automatically.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
