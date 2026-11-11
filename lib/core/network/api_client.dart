import 'dart:async';
import 'dart:convert';
import 'package:mystore/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _http = http.Client();
  final TokenStorage _storage = TokenStorage.instance;

  // يُستدعى عندما يرفض السيرفر التوكن (منتهي أو غير صالح)
  void Function()? onSessionExpired;

  // كاش ETag في الذاكرة: الرابط الكامل (مع الـ query) -> آخر ETag وجسم الرد
  // يُستخدم فقط للمنتجات وتفاصيل المنتج والتصنيفات
  static const int _maxCacheEntries = 200;
  final Map<String, _CachedResponse> _etagCache = {};

  // etag: true يفعّل If-None-Match، فإن رد السيرفر 304 نرجع الجسم المحفوظ
  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
    bool etag = false,
  }) => _send('GET', path, query: query, auth: auth, etag: etag);

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => _send('PUT', path, body: body, auth: auth);

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => _send('PATCH', path, body: body, auth: auth);

  Future<dynamic> delete(String path, {bool auth = true}) =>
      _send('DELETE', path, auth: auth);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    required bool auth,
    bool etag = false,
  }) async {
    final Uri url = _buildUrl(path, query);
    final String cacheKey = url.toString();
    final _CachedResponse? cached = etag ? _etagCache[cacheKey] : null;

    final response = await _request(
      method,
      url,
      body: body,
      token: auth ? _storage.accessToken : null,
      ifNoneMatch: cached?.etag,
    );

    // السيرفر لا يدعم تجديد التوكن، فعند رفضه ننهي الجلسة مباشرة
    if (response.statusCode == 401 && auth) {
      await _storage.clear();
      onSessionExpired?.call();
    }

    // 304: لم يتغير شيء ولم يُحمَّل أي جسم، نستخدم النسخة المحفوظة
    if (response.statusCode == 304 && cached != null) {
      _remember(cacheKey, cached);
      return _decode(cached.body);
    }

    if (etag && response.statusCode == 200) {
      final String? newEtag = response.headers['etag'];
      if (newEtag != null && newEtag.isNotEmpty) {
        _remember(cacheKey, _CachedResponse(newEtag, response.bodyBytes));
      } else {
        _etagCache.remove(cacheKey);
      }
    }

    return _parse(response);
  }

  // نعيد إدخال العنصر ليصبح الأحدث، ونحذف الأقدم إن امتلأ الكاش
  void _remember(String key, _CachedResponse value) {
    _etagCache.remove(key);
    _etagCache[key] = value;
    if (_etagCache.length > _maxCacheEntries) {
      _etagCache.remove(_etagCache.keys.first);
    }
  }

  Uri _buildUrl(String path, Map<String, String>? query) =>
      Uri.parse('${ApiEndpoints.baseUrl}$path').replace(queryParameters: query);

  Future<http.Response> _request(
    String method,
    Uri url, {
    Map<String, dynamic>? body,
    String? token,
    String? ifNoneMatch,
  }) async {
    final request = http.Request(method, url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // التطبيق عربي فقط، فنطلب رسائل السيرفر بالعربية
        'Accept-Language': 'ar',
        if (token != null) 'Authorization': 'Bearer $token',
        'If-None-Match': ?ifNoneMatch,
      });
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _http.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('انتهت مهلة الاتصال، حاول مجدداً');
    } on http.ClientException {
      throw ApiException('تعذر الاتصال بالسيرفر، تحقق من الإنترنت');
    }
  }

  dynamic _parse(http.Response response) {
    final dynamic data = _decode(response.bodyBytes);

    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    throw ApiException.fromResponse(response.statusCode, data);
  }

  dynamic _decode(List<int> bytes) {
    try {
      return bytes.isEmpty ? null : jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return null;
    }
  }
}

class _CachedResponse {
  final String etag;
  final List<int> body;

  _CachedResponse(this.etag, this.body);
}
