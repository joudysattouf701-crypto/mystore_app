class AppMoney {
  // مبلغ بالليرة السورية مع فواصل الآلاف: 5,000,000 ل.س
  static String format(int amount) {
    final String grouped = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$grouped ل.س';
  }
}
