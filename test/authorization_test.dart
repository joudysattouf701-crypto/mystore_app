// اختبار سريع لحالات الـ authentication و الـ authorization على السيرفر الحقيقي.
// بدل ما نسجل دخول ونطلع ونرجع نفوت بحساب تاني يدوياً، الاختبار:
//   1. ينشئ زبونين جديدين (A و B) تلقائياً ويأخذ توكن كل واحد
//   2. يجرب الطلبات بدون توكن / بتوكن مزوّر / بتوكن زبون على عملية أدمن
//   3. يتحقق أن زبون B لا يستطيع رؤية طلب زبون A
//
// التشغيل:
//   flutter test test/authorization_test.dart --reporter expanded

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mystore/core/network/api_endpoints.dart';

class _User {
  final int id;
  final String email;
  final String role;
  final String token;
  _User(this.id, this.email, this.role, this.token);
}

class _Res {
  final int status;
  final dynamic body;
  _Res(this.status, this.body);

  String? get errorCode =>
      body is Map && body['error'] is Map ? body['error']['code'] : null;
}

Future<_Res> _call(
  String method,
  String path, {
  String? token,
  Map<String, dynamic>? body,
}) async {
  final request =
      http.Request(method, Uri.parse('${ApiEndpoints.baseUrl}$path'))
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        });
  if (body != null) request.body = jsonEncode(body);

  final response = await http.Response.fromStream(await request.send());
  dynamic data;
  try {
    data = jsonDecode(utf8.decode(response.bodyBytes));
  } catch (_) {
    data = null;
  }
  // ignore: avoid_print
  print('   $method $path  [${token == null ? 'no token' : 'token'}]'
      '  ->  ${response.statusCode} ${data is Map && data['error'] is Map ? data['error']['code'] : ''}');
  return _Res(response.statusCode, data);
}

Future<_User> _registerCustomer(String label) async {
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final res = await _call('POST', ApiEndpoints.register, body: {
    'name': 'Auth Test $label',
    'email': 'authtest_${label}_$stamp@test.com',
    'password': 'Password123',
    'password_confirmation': 'Password123',
  });
  expect(res.status, anyOf(200, 201), reason: 'register $label failed');
  final data = res.body['data'];
  return _User(
    data['user']['id'],
    data['user']['email'],
    data['user']['role'],
    data['access_token'],
  );
}

void main() {
  late _User a;
  late _User b;

  setUpAll(() async {
    a = await _registerCustomer('A');
    b = await _registerCustomer('B');
    // ignore: avoid_print
    print('Customer A: id=${a.id}  ${a.email}\n'
        'Customer B: id=${b.id}  ${b.email}');
  });

  group('Authentication (401)', () {
    test('no token -> 401 on /auth/me', () async {
      final res = await _call('GET', ApiEndpoints.me);
      expect(res.status, 401);
      expect(res.errorCode, 'UNAUTHENTICATED');
    });

    test('no token -> 401 on /orders', () async {
      final res = await _call('GET', ApiEndpoints.orders);
      expect(res.status, 401);
    });

    test('fake token -> 401', () async {
      final res = await _call('GET', ApiEndpoints.me, token: 'fake.token.123');
      expect(res.status, 401);
    });

    test('tampered token (A token with last chars changed) -> 401', () async {
      final tampered =
          '${a.token.substring(0, a.token.length - 4)}AAAA';
      final res = await _call('GET', ApiEndpoints.me, token: tampered);
      expect(res.status, 401);
    });
  });

  group('Token identifies the right user', () {
    test('A token returns A, B token returns B', () async {
      final meA = await _call('GET', ApiEndpoints.me, token: a.token);
      final meB = await _call('GET', ApiEndpoints.me, token: b.token);
      expect(meA.status, 200);
      expect(meB.status, 200);
      expect(meA.body['data']['id'], a.id);
      expect(meB.body['data']['id'], b.id);
      expect(meA.body['data']['role'], 'customer');
    });
  });

  group('Role authorization (403)', () {
    test('customer cannot create a product (admin only) -> 403', () async {
      final res = await _call('POST', ApiEndpoints.products,
          token: a.token, body: {'name': 'hack', 'price': 1});
      expect(res.status, 403);
      expect(res.errorCode, 'FORBIDDEN');
    });
  });

  group('Ownership: B cannot see A\'s order', () {
    test('A creates order, B gets 404, A gets 200', () async {
      final products = await _call('GET', ApiEndpoints.products);
      final List list = products.body['data'] ?? [];
      if (list.isEmpty) {
        markTestSkipped('No products in the database, cannot create an order');
        return;
      }

      final created = await _call('POST', ApiEndpoints.orders,
          token: a.token,
          body: {
            'items': [
              {'product_id': list.first['id'], 'quantity': 1},
            ],
          });
      expect(created.status, anyOf(200, 201));
      final int orderId = created.body['data']['id'];

      final asOwner =
          await _call('GET', ApiEndpoints.order(orderId), token: a.token);
      expect(asOwner.status, 200);

      final asOther =
          await _call('GET', ApiEndpoints.order(orderId), token: b.token);
      expect(asOther.status, anyOf(403, 404));

      final listB = await _call('GET', ApiEndpoints.orders, token: b.token);
      final List ordersB = listB.body['data'] ?? [];
      expect(ordersB.any((o) => o['id'] == orderId), isFalse,
          reason: 'A\'s order must not appear in B\'s list');
    });
  });
}
