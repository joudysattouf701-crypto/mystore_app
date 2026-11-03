import 'package:flutter_test/flutter_test.dart';
import 'package:mystore/core/utils/app_validators.dart';

void main() {
  group('email', () {
    test('rejects empty and malformed emails', () {
      expect(AppValidators.email(''), isNotNull);
      expect(AppValidators.email('ahmad'), isNotNull);
      expect(AppValidators.email('ahmad@example'), isNotNull);
    });

    test('accepts a valid email', () {
      expect(AppValidators.email('ahmad@example.com'), isNull);
    });
  });

  group('password', () {
    test('requires at least 8 characters', () {
      expect(AppValidators.password('abc123'), isNotNull);
    });

    test('requires a letter and a digit', () {
      expect(AppValidators.password('abcdefgh'), isNotNull);
      expect(AppValidators.password('12345678'), isNotNull);
    });

    test('accepts a valid password', () {
      expect(AppValidators.password('Secret123'), isNull);
    });
  });

  test('confirmPassword compares against the password', () {
    final validator = AppValidators.confirmPassword(() => 'Secret123');
    expect(validator('Secret124'), isNotNull);
    expect(validator('Secret123'), isNull);
  });

  test('name is required and at most 100 characters', () {
    expect(AppValidators.name('  '), isNotNull);
    expect(AppValidators.name('a' * 101), isNotNull);
    expect(AppValidators.name('أحمد'), isNull);
  });
}
