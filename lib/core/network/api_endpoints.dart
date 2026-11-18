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

  // Realtime: توقيع الاشتراك بالقنوات الخاصة (POST + JWT)
  static const String broadcastingAuth = '/broadcasting/auth';
}

// إعدادات سيرفر الـ WebSocket (Laravel Reverb، بروتوكول Pusher).
// القيم تتغير وقت النشر فلا تُكتب جوّا الكود، تُمرَّر عند التشغيل:
//   flutter run --dart-define=REVERB_HOST=10.0.2.2 --dart-define=REVERB_PORT=8080 \
//     --dart-define=REVERB_SCHEME=ws --dart-define=REVERB_APP_KEY=xxxx
// الـ App Key عام (يظهر بعنوان الاتصال)، الحماية من الـ JWT وتوقيع الـ backend.
class RealtimeConfig {
  static const String host = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: 'gateway-production-dacf.up.railway.app',
  );
  static const int port = int.fromEnvironment('REVERB_PORT', defaultValue: 443);
  // wss مع TLS على الإنتاج، و ws محلياً
  static const String scheme = String.fromEnvironment(
    'REVERB_SCHEME',
    defaultValue: 'wss',
  );
  static const String appKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: '5add4a82a2ea9b5a6217cec6e56b53e0',
  );

  // القنوات (خاصة، وبادئة private- مطلوبة هنا بعكس Laravel Echo)
  static String userChannel(int userId) => 'private-user.$userId';

  // أسماء الأحداث كما يرسلها السيرفر
  static const String orderStatusChangedEvent = 'order.status_changed';
}
