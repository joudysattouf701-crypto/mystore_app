class ApiEndpoints {
  static const String baseUrl =
      'https://gateway-production-dacf.up.railway.app/api/v1';

  // الدور المسموح له بالدخول لأن هذا تطبيق الزبون فقط
  static const String role = 'customer';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Products
  static const String categories = '/categories';
  static const String products = '/products';
  static String product(int id) => '/products/$id';

  // Orders
  static const String orders = '/orders';
  static String order(int id) => '/orders/$id';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';
}
