import 'package:flutter_test/flutter_test.dart';
import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_money.dart';
import 'package:mystore/features/authentication/login/login_model.dart';
import 'package:mystore/features/products/products_list/products_list_model.dart';

void main() {
  test('LoginModel reads the token and user from data', () {
    final model = LoginModel.fromJson({
      'data': {
        'user': {
          'id': 2,
          'name': 'أحمد',
          'email': 'ahmad@example.com',
          'role': 'customer',
        },
        'access_token': 'token',
        'token_type': 'Bearer',
        'expires_in': 3600,
      },
    });

    expect(model.accessToken, 'token');
    expect(model.expiresIn, 3600);
    expect(model.user.name, 'أحمد');
    expect(model.user.isCustomer, isTrue);
  });

  test('ProductsListModel reads products and pagination', () {
    final model = ProductsListModel.fromJson({
      'data': [
        {
          'id': 1,
          'name': 'Laptop',
          'description': null,
          'price': 5000000,
          'category': {'id': 3, 'name': 'إلكترونيات'},
          'image_url': 'https://example.com/laptop.webp',
          'created_at': '2026-11-01T10:00:00Z',
        },
      ],
      'meta': {'current_page': 1, 'per_page': 15, 'total': 16, 'last_page': 2},
    });

    expect(model.products.single.name, 'Laptop');
    expect(model.products.single.category?.name, 'إلكترونيات');
    expect(model.products.single.description, isNull);
    expect(model.meta.hasMore, isTrue);
  });

  test('ApiException reads the unified error format', () {
    final e = ApiException.fromResponse(422, {
      'error': {
        'code': 'VALIDATION_FAILED',
        'message': 'البيانات المدخلة غير صحيحة',
        'details': {
          'email': ['البريد الإلكتروني مستخدم مسبقاً'],
        },
      },
    });

    expect(e.code, 'VALIDATION_FAILED');
    expect(e.statusCode, 422);
    expect(e.displayMessage, 'البريد الإلكتروني مستخدم مسبقاً');
  });

  test('ApiException falls back to a generic message', () {
    final e = ApiException.fromResponse(500, null);
    expect(e.displayMessage, contains('500'));
  });

  test('AppMoney groups thousands', () {
    expect(AppMoney.format(5000000), '5,000,000 ل.س');
    expect(AppMoney.format(750), '750 ل.س');
  });
}
