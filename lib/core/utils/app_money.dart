class AppMoney {
  static String format(int amount) {
    final String grouped = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$grouped ل.س';
  }
}
