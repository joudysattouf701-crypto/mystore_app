class ApiEndpoints {
  static const String baseUrl =
      'https://gateway-production-dacf.up.railway.app/api/v1';

  static const String role = 'customer';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  static const String categories = '/categories';
  static const String products = '/products';
  static String product(int id) => '/products/$id';

  static const String orders = '/orders';
  static String order(int id) => '/orders/$id';

  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';

  static const String broadcastingAuth = '/broadcasting/auth';
}

class RealtimeConfig {
  static const String host = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: 'gateway-production-dacf.up.railway.app',
  );
  static const int port = int.fromEnvironment('REVERB_PORT', defaultValue: 443);
  static const String scheme = String.fromEnvironment(
    'REVERB_SCHEME',
    defaultValue: 'wss',
  );
  static const String appKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: '5add4a82a2ea9b5a6217cec6e56b53e0',
  );

  static String userChannel(int userId) => 'private-user.$userId';

  static const String orderStatusChangedEvent = 'order.status_changed';
}
