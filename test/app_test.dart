// اختبار شامل للتطبيق في ملف واحد:
//   1. السلة (بدون سيرفر)
//   2. تحويل JSON للطلبات والإشعارات ورسائل الأخطاء (بدون سيرفر)
//   3. الـ authentication و الـ authorization على السيرفر الحقيقي
//   4. إنشاء الطلبات على السيرفر الحقيقي
//
// التشغيل:
//   flutter test test/app_test.dart --reporter expanded

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mystore/core/network/api_endpoints.dart';
import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/cart/cart_controller.dart';
import 'package:mystore/features/cart/cart_model.dart';
import 'package:mystore/features/notifications/notification_model.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:mystore/features/products/product_details/product_details_model.dart';

// ───────────────────────── helpers ─────────────────────────

ProductModel _product(int id, {int price = 1000}) =>
    ProductModel(id: id, name: 'Product $id', price: price, imageUrl: '');

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
  final res = _Res(response.statusCode, data);
  // ignore: avoid_print
  print('   $method $path  [${token == null ? 'no token' : 'token'}]'
      '  ->  ${res.status} ${res.errorCode ?? ''}');
  return res;
}

Future<_User> _registerCustomer(String label) async {
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final res = await _call('POST', ApiEndpoints.register, body: {
    'name': 'Test $label',
    'email': 'apptest_${label}_$stamp@test.com',
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

// ───────────────────────── tests ─────────────────────────

void main() {
  // ═════════════ 1. Cart (offline) ═════════════
  group('1. Cart', () {
    late CartController cart;

    setUp(() {
      Get.testMode = true;
      Get.put(AuthSession());
      cart = Get.put(CartController());
    });

    tearDown(Get.reset);

    test('item subtotal = price * quantity', () {
      final item =
          CartItemModel(product: _product(1, price: 2500), quantity: 3);
      expect(item.subtotal, 7500);
    });

    test('item toJson sends only product_id and quantity', () {
      final item = CartItemModel(product: _product(7), quantity: 2);
      expect(item.toJson(), {'product_id': 7, 'quantity': 2});
    });

    test('add a new product', () {
      cart.add(_product(1), 2);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
    });

    test('same product is merged into one line', () {
      cart.add(_product(1), 2);
      cart.add(_product(1), 3);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 5);
    });

    test('different products are separate lines', () {
      cart.add(_product(1), 1);
      cart.add(_product(2), 1);
      expect(cart.items.length, 2);
    });

    test('quantity is capped at maxQuantity', () {
      cart.add(_product(1), 500);
      expect(cart.items.first.quantity, CartController.maxQuantity);
      cart.add(_product(1), 10);
      expect(cart.items.first.quantity, CartController.maxQuantity);
    });

    test('adding with quantity 0 becomes 1', () {
      cart.add(_product(1), 0);
      expect(cart.items.first.quantity, 1);
    });

    test('setQuantity changes the quantity', () {
      cart.add(_product(1), 1);
      cart.setQuantity(1, 4);
      expect(cart.items.first.quantity, 4);
    });

    test('setQuantity 0 removes the item', () {
      cart.add(_product(1), 1);
      cart.setQuantity(1, 0);
      expect(cart.items, isEmpty);
    });

    test('setQuantity above max is capped', () {
      cart.add(_product(1), 1);
      cart.setQuantity(1, 1000);
      expect(cart.items.first.quantity, CartController.maxQuantity);
    });

    test('setQuantity on a missing product does nothing', () {
      cart.add(_product(1), 1);
      cart.setQuantity(99, 5);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 1);
    });

    test('remove deletes only that product', () {
      cart.add(_product(1), 1);
      cart.add(_product(2), 1);
      cart.remove(1);
      expect(cart.items.map((i) => i.product.id), [2]);
    });

    test('clear empties the cart', () {
      cart.add(_product(1), 1);
      cart.add(_product(2), 1);
      cart.clear();
      expect(cart.items, isEmpty);
    });

    test('empty cart: count 0, total 0', () {
      expect(cart.count, 0);
      expect(cart.total, 0);
    });

    test('count sums quantities, total sums subtotals', () {
      cart.add(_product(1, price: 1000), 2); // 2000
      cart.add(_product(2, price: 500), 3); // 1500
      expect(cart.count, 5);
      expect(cart.total, 3500);
    });

    test('cart is cleared on logout', () async {
      AuthSession.to.isLoggedIn.value = true;
      cart.add(_product(1), 2);
      AuthSession.to.isLoggedIn.value = false;
      await Future<void>.delayed(Duration.zero);
      expect(cart.items, isEmpty);
    });

    test('cart is kept while logged in', () async {
      AuthSession.to.isLoggedIn.value = true;
      cart.add(_product(1), 2);
      await Future<void>.delayed(Duration.zero);
      expect(cart.items.length, 1);
    });
  });

  // ═════════════ 2. Models (offline) ═════════════
  group('2. Models', () {
    group('OrderStatus', () {
      test('parses every known status', () {
        expect(OrderStatus.fromJson('pending'), OrderStatus.pending);
        expect(OrderStatus.fromJson('confirmed'), OrderStatus.confirmed);
        expect(OrderStatus.fromJson('shipped'), OrderStatus.shipped);
        expect(OrderStatus.fromJson('delivered'), OrderStatus.delivered);
        expect(OrderStatus.fromJson('cancelled'), OrderStatus.cancelled);
      });

      test('unknown or null status falls back to pending', () {
        expect(OrderStatus.fromJson('weird'), OrderStatus.pending);
        expect(OrderStatus.fromJson(null), OrderStatus.pending);
      });
    });

    group('OrderModel', () {
      final json = {
        'id': 12,
        'customer_id': 3,
        'status': 'shipped',
        'total': 7000,
        'items': [
          {
            'product_id': 1,
            'product_name': 'Shirt',
            'unit_price': 2000,
            'quantity': 2,
            'subtotal': 4000,
          },
          {
            'product_id': 2,
            'product_name': 'Hat',
            'unit_price': 1000,
            'quantity': 3,
            'subtotal': 3000,
          },
        ],
        'status_history': [
          {
            'from': 'pending',
            'to': 'confirmed',
            'changed_by': 1,
            'note': null,
            'changed_at': '2026-11-01T10:00:00Z',
          },
          {
            'from': 'confirmed',
            'to': 'shipped',
            'changed_by': 1,
            'note': 'on the way',
            'changed_at': '2026-11-02T10:00:00Z',
          },
        ],
        'created_at': '2026-11-01T09:00:00Z',
        'updated_at': '2026-11-02T10:00:00Z',
      };

      test('fromJson reads all fields', () {
        final order = OrderModel.fromJson(json);
        expect(order.id, 12);
        expect(order.customerId, 3);
        expect(order.status, OrderStatus.shipped);
        expect(order.total, 7000);
        expect(order.items.length, 2);
        expect(order.items.first.productName, 'Shirt');
        expect(order.items.first.unitPrice, 2000);
        expect(order.statusHistory.length, 2);
        expect(order.statusHistory.last.to, OrderStatus.shipped);
        expect(order.statusHistory.last.note, 'on the way');
        expect(order.createdAt, DateTime.utc(2026, 11, 1, 9));
      });

      test('quantity sums item quantities', () {
        expect(OrderModel.fromJson(json).quantity, 5);
      });

      test('list response without items/history does not crash', () {
        final order = OrderModel.fromJson({'id': 1, 'status': 'pending'});
        expect(order.items, isEmpty);
        expect(order.statusHistory, isEmpty);
        expect(order.total, 0);
        expect(order.createdAt, isNull);
      });

      test('toJson -> fromJson round trip keeps the data', () {
        final order = OrderModel.fromJson(json);
        final again = OrderModel.fromJson(order.toJson());
        expect(again.id, order.id);
        expect(again.status, order.status);
        expect(again.total, order.total);
        expect(again.items.length, order.items.length);
        expect(again.statusHistory.length, order.statusHistory.length);
        expect(again.createdAt, order.createdAt);
      });
    });

    group('NotificationModel', () {
      test('unread order notification', () {
        final n = NotificationModel.fromJson({
          'id': 5,
          'type': 'order_status_changed',
          'title': 'Order shipped',
          'data': {'order_id': 12, 'status': 'shipped'},
          'read_at': null,
          'created_at': '2026-11-02T10:00:00Z',
        });
        expect(n.type, NotificationModel.orderStatusChanged);
        expect(n.isRead, isFalse);
        expect(n.orderId, 12);
        expect(n.orderStatus, OrderStatus.shipped);
      });

      test('read notification', () {
        final n = NotificationModel.fromJson(
            {'id': 6, 'read_at': '2026-11-03T10:00:00Z'});
        expect(n.isRead, isTrue);
      });

      test('missing data gives null order info', () {
        final n = NotificationModel.fromJson({'id': 7, 'data': null});
        expect(n.orderId, isNull);
        expect(n.orderStatus, isNull);
      });
    });

    group('ApiException', () {
      test('reads code, message and field errors', () {
        final e = ApiException.fromResponse(422, {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid data',
            'details': {
              'items.0.product_id': ['Product not found'],
              'items.1.quantity': ['Too many', 'second message'],
            },
          },
        });
        expect(e.statusCode, 422);
        expect(e.code, 'VALIDATION_ERROR');
        expect(e.errors.length, 2);
        expect(e.displayMessage, 'Product not found\nToo many');
      });

      test('no details -> shows the general message', () {
        final e = ApiException.fromResponse(403, {
          'error': {'code': 'FORBIDDEN', 'message': 'Not allowed'},
        });
        expect(e.errors, isEmpty);
        expect(e.displayMessage, 'Not allowed');
      });

      test('non-JSON body -> fallback message with status code', () {
        final e = ApiException.fromResponse(500, null);
        expect(e.code, isNull);
        expect(e.displayMessage, contains('500'));
      });
    });
  });

  // ═════════════ 3 + 4. Live server ═════════════
  group('Live server', () {
    late _User a;
    late _User b;
    late List products;

    setUpAll(() async {
      a = await _registerCustomer('A');
      b = await _registerCustomer('B');
      final res = await _call('GET', ApiEndpoints.products);
      products = res.body['data'] ?? [];
      // ignore: avoid_print
      print('Customer A: id=${a.id}  ${a.email}\n'
          'Customer B: id=${b.id}  ${b.email}\n'
          'Products in database: ${products.length}');
    });

    group('3. Authentication (401)', () {
      test('no token -> 401 on /auth/me', () async {
        final res = await _call('GET', ApiEndpoints.me);
        expect(res.status, 401);
        expect(res.errorCode, 'UNAUTHENTICATED');
      });

      test('no token -> 401 on /orders', () async {
        final res = await _call('GET', ApiEndpoints.orders);
        expect(res.status, 401);
      });

      test('no token -> 401 on /notifications', () async {
        final res = await _call('GET', ApiEndpoints.notifications);
        expect(res.status, 401);
      });

      test('fake token -> 401', () async {
        final res =
            await _call('GET', ApiEndpoints.me, token: 'fake.token.123');
        expect(res.status, 401);
      });

      test('tampered token -> 401', () async {
        final tampered = '${a.token.substring(0, a.token.length - 4)}AAAA';
        final res = await _call('GET', ApiEndpoints.me, token: tampered);
        expect(res.status, 401);
      });

      test('A token returns A, B token returns B', () async {
        final meA = await _call('GET', ApiEndpoints.me, token: a.token);
        final meB = await _call('GET', ApiEndpoints.me, token: b.token);
        expect(meA.status, 200);
        expect(meB.status, 200);
        expect(meA.body['data']['id'], a.id);
        expect(meB.body['data']['id'], b.id);
        expect(meA.body['data']['role'], 'customer');
      });

      test('customer cannot create a product (admin only) -> 403', () async {
        final res = await _call('POST', ApiEndpoints.products,
            token: a.token, body: {'name': 'hack', 'price': 1});
        expect(res.status, 403);
        expect(res.errorCode, 'FORBIDDEN');
      });
    });

    group('4. Orders', () {
      test('new customer has no orders', () async {
        final res = await _call('GET', ApiEndpoints.orders, token: a.token);
        expect(res.status, 200);
        expect(res.body['data'], isEmpty);
      });

      test('create order from the cart: pending, correct total, '
          'only owner can see it', () async {
        if (products.length < 2) {
          markTestSkipped('Need at least 2 products in the database');
          return;
        }
        final p1 = products[0];
        final p2 = products[1];

        // نبني الطلب من السلة كما يفعل التطبيق تماماً
        Get.testMode = true;
        Get.put(AuthSession());
        final cart = Get.put(CartController());
        cart.add(ProductModel.fromJson(p1), 1);
        cart.add(ProductModel.fromJson(p1), 1); // يُدمج => كمية 2
        cart.add(ProductModel.fromJson(p2), 1);
        final body = {'items': cart.items.map((i) => i.toJson()).toList()};
        final int cartTotal = cart.total;
        Get.reset();

        final created =
            await _call('POST', ApiEndpoints.orders, token: a.token, body: body);
        expect(created.status, anyOf(200, 201));

        final order = created.body['data'];
        final int orderId = order['id'];
        expect(order['status'], 'pending');
        expect((order['items'] as List).length, 2);
        expect(order['total'], cartTotal,
            reason: 'server total must match the cart total');

        // يظهر عند A في القائمة والتفاصيل
        final listA = await _call('GET', ApiEndpoints.orders, token: a.token);
        expect(
            (listA.body['data'] as List).any((o) => o['id'] == orderId), isTrue);
        final asOwner =
            await _call('GET', ApiEndpoints.order(orderId), token: a.token);
        expect(asOwner.status, 200);
        expect(asOwner.body['data']['total'], cartTotal);

        // لا يظهر عند B
        final asOther =
            await _call('GET', ApiEndpoints.order(orderId), token: b.token);
        expect(asOther.status, anyOf(403, 404));
        final listB = await _call('GET', ApiEndpoints.orders, token: b.token);
        expect((listB.body['data'] as List).any((o) => o['id'] == orderId),
            isFalse,
            reason: 'A\'s order must not appear in B\'s list');
      });

      test('reject: empty items -> 422', () async {
        final res = await _call('POST', ApiEndpoints.orders,
            token: a.token, body: {'items': []});
        expect(res.status, 422);
      });

      test('reject: quantity 0 -> 422', () async {
        if (products.isEmpty) return markTestSkipped('No products');
        final res =
            await _call('POST', ApiEndpoints.orders, token: a.token, body: {
          'items': [
            {'product_id': products.first['id'], 'quantity': 0},
          ],
        });
        expect(res.status, 422);
      });

      test('reject: product that does not exist', () async {
        final res =
            await _call('POST', ApiEndpoints.orders, token: a.token, body: {
          'items': [
            {'product_id': 999999999, 'quantity': 1},
          ],
        });
        expect(res.status, anyOf(404, 422));
      });

      test('reject: same product twice -> 422', () async {
        if (products.isEmpty) return markTestSkipped('No products');
        final id = products.first['id'];
        final res =
            await _call('POST', ApiEndpoints.orders, token: a.token, body: {
          'items': [
            {'product_id': id, 'quantity': 1},
            {'product_id': id, 'quantity': 1},
          ],
        });
        expect(res.status, 422);
      });

      test('order that does not exist -> 404', () async {
        final res = await _call('GET', ApiEndpoints.order(999999999),
            token: a.token);
        expect(res.status, 404);
      });
    });
  });
}
