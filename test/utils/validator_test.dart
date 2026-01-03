import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/utils/validator.dart';

void main() {
  group('Validator', () {
    group('validateEmail', () {
      test('returns error for null value', () {
        expect(Validator.validateEmail(null), 'Please enter your email');
      });

      test('returns error for empty string', () {
        expect(Validator.validateEmail(''), 'Please enter your email');
      });

      test('returns error for invalid email - no @', () {
        expect(Validator.validateEmail('notanemail'), 'Please enter a valid email');
      });

      test('returns error for invalid email - no domain', () {
        expect(Validator.validateEmail('user@'), 'Please enter a valid email');
      });

      test('returns error for invalid email - no local part', () {
        expect(Validator.validateEmail('@example.com'), 'Please enter a valid email');
      });

      test('returns error for invalid email - no TLD', () {
        expect(Validator.validateEmail('user@example'), 'Please enter a valid email');
      });

      test('returns error for invalid email - spaces', () {
        expect(Validator.validateEmail('user name@example.com'), 'Please enter a valid email');
      });

      test('returns null for valid simple email', () {
        expect(Validator.validateEmail('user@example.com'), null);
      });

      test('returns null for valid email with subdomain', () {
        expect(Validator.validateEmail('user@mail.example.com'), null);
      });

      test('returns null for valid email with dots in local part', () {
        expect(Validator.validateEmail('user.name@example.com'), null);
      });

      test('returns null for valid email with plus tag', () {
        expect(Validator.validateEmail('user+tag@example.com'), null);
      });

      test('returns null for valid email with country TLD', () {
        expect(Validator.validateEmail('user@example.co.uk'), null);
      });
    });

    group('validatePassword', () {
      test('returns error for null value', () {
        expect(Validator.validatePassword(null), 'Please enter your password');
      });

      test('returns error for empty string', () {
        expect(Validator.validatePassword(''), 'Please enter your password');
      });

      test('returns error for password with 1 character', () {
        expect(
          Validator.validatePassword('a'),
          'Password should be at least 6 characters',
        );
      });

      test('returns error for password with 5 characters', () {
        expect(
          Validator.validatePassword('12345'),
          'Password should be at least 6 characters',
        );
      });

      test('returns null for password with exactly 6 characters', () {
        expect(Validator.validatePassword('123456'), null);
      });

      test('returns null for password with more than 6 characters', () {
        expect(Validator.validatePassword('password123'), null);
      });

      test('returns null for long password', () {
        expect(Validator.validatePassword('thisisaverylongpassword'), null);
      });
    });
  });
}
