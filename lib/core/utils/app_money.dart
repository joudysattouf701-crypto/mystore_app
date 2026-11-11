class AppMoney {
  // كل المبالغ من السيرفر أعداد صحيحة بالسنت الأمريكي، نقسم على 100 للعرض فقط
  // مثال: 37999 -> $379.99 ، و 123456789 -> $1,234,567.89
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

  // عند إرسال سعر للسيرفر: دولار -> سنت، دائماً عدد صحيح
  static int toCents(num dollars) => (dollars * 100).round();
}
