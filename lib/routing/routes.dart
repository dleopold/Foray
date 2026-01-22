abstract class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/';
  static const String settings = '/settings';

  static const String forays = '/forays';
  static const String forayDetail = '/forays/:id';
  static const String createForay = '/forays/create';
  static const String joinForay = '/forays/join';

  static const String observationDetail = '/observations/:id';
  static const String createObservation = '/forays/:forayId/observations/create';
  static const String editObservation = '/observations/:id/edit';

  static const String navigate = '/navigate/:observationId';

  static const String personalMap = '/map';
}
