abstract class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Main
  static const String home = '/';
  static const String settings = '/settings';

  // Forays
  static const String forays = '/forays';
  static const String forayDetail = '/forays/:id';
  static const String createForay = '/forays/create';
  static const String joinForay = '/forays/join';

  // Observations
  static const String observationDetail = '/observations/:id';
  static const String createObservation = '/forays/:forayId/observations/create';
  static const String editObservation = '/observations/:id/edit';

  // Navigation
  static const String navigate = '/navigate/:observationId';

  // Maps
  static const String personalMap = '/map';

  // Development
  static const String devComponents = '/dev/components';
}
