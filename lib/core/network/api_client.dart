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

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) => _send('GET', path, query: query, auth: auth);

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
  }) async {
    final response = await _request(
      method,
      path,
      body: body,
      query: query,
      token: auth ? _storage.accessToken : null,
    );

    // السيرفر لا يدعم تجديد التوكن، فعند رفضه ننهي الجلسة مباشرة
    if (response.statusCode == 401 && auth) {
      await _storage.clear();
      onSessionExpired?.call();
    }

    return _parse(response);
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String? token,
  }) async {
    final Uri url = Uri.parse(
      '${ApiEndpoints.baseUrl}$path',
    ).replace(queryParameters: query);

    final request = http.Request(method, url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // التطبيق عربي فقط، فنطلب رسائل السيرفر بالعربية
        'Accept-Language': 'ar',
        if (token != null) 'Authorization': 'Bearer $token',
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
    dynamic data;
    try {
      data = response.bodyBytes.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      data = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    throw ApiException.fromResponse(response.statusCode, data);
  }
}
