class AppMoney {
  static String format(int cents) {
    final String sign = cents < 0 ? '-' : '';
    final int abs = cents.abs();

    final String dollars = (abs ~/ 100).toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final String rest = (abs % 100).toString().padLeft(2, '0');

    return '$sign\$$dollars.$rest';
  }

  static int toCents(num dollars) => (dollars * 100).round();
}
