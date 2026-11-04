import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const String _accessKey = 'access_token';
  static const String _userKey = 'user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // نسخة في الذاكرة حتى لا نقرأ من التخزين مع كل طلب
  String? accessToken;
  String? userJson;

  Future<void> load() async {
    try {
      accessToken = await _storage.read(key: _accessKey);
      userJson = await _storage.read(key: _userKey);
    } catch (_) {
      // تخزين تالف أو غير مقروء: نعتبر المستخدم غير مسجل الدخول
      accessToken = null;
      userJson = null;
    }
  }

  Future<void> saveToken(String access) async {
    accessToken = access;
    await _storage.write(key: _accessKey, value: access);
  }

  Future<void> saveUser(String json) async {
    userJson = json;
    await _storage.write(key: _userKey, value: json);
  }

  Future<void> clear() async {
    accessToken = null;
    userJson = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _userKey);
  }
}
