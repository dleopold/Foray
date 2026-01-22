abstract class AppConstants {
  static const String appName = 'Foray';
  static const String appVersion = '1.0.0';

  static const double defaultGpsAccuracyThreshold = 50.0;
  static const int gpsTimeoutSeconds = 30;

  static const int maxPhotosPerObservation = 10;
  static const int photoCompressionQuality = 85;
  static const int photoMaxDimension = 2048;

  static const double arrivalThresholdMeters = 10.0;
  static const double farDistanceThresholdKm = 50.0;

  static const int syncRetryMaxAttempts = 3;
  static const Duration syncRetryBaseDelay = Duration(seconds: 5);

  static const int joinCodeLength = 6;
}
