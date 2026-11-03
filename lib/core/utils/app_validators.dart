// قواعد التحقق المشتركة بين شاشات المصادقة (مطابقة لقواعد السيرفر)
class AppValidators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _letter = RegExp(r'[A-Za-z؀-ۿ]');
  static final RegExp _digit = RegExp(r'\d');

  static String? required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    return value.trim().length > 100 ? 'الاسم 100 حرف كحد أقصى' : null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    return _emailPattern.hasMatch(value.trim())
        ? null
        : 'البريد الإلكتروني غير صحيح';
  }

  // السيرفر يشترط 8 أحرف على الأقل وفيها حرف ورقم
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value.length < 8) return 'كلمة المرور 8 أحرف على الأقل';
    if (!_letter.hasMatch(value) || !_digit.hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي حرفاً ورقماً على الأقل';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) =>
        value != password() ? 'كلمتا المرور غير متطابقتين' : null;
  }
}
