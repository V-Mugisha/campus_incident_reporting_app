import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/utils/validators.dart';

void main() {
  group('validateName', () {
    test('rejects empty and whitespace', () {
      expect(validateName(null), 'Full name is required');
      expect(validateName(''), 'Full name is required');
      expect(validateName('   '), 'Full name is required');
    });

    test('rejects too short after trimming', () {
      expect(validateName('a'), 'Full name must be at least 2 characters');
    });

    test('accepts valid', () {
      expect(validateName('Amina'), null);
      expect(validateName(' ab '), null);
    });
  });

  group('validateEmail', () {
    test('rejects empty', () {
      expect(validateEmail(null), 'Email is required');
      expect(validateEmail('   '), 'Email is required');
    });

    test('rejects invalid format', () {
      expect(validateEmail('foo'), 'Please enter a valid email address');
      expect(validateEmail('foo@bar'), 'Please enter a valid email address');
    });

    test('accepts valid', () {
      expect(validateEmail('a@b.com'), null);
      expect(validateEmail('user.name@example.co'), null);
    });
  });

  group('validatePassword', () {
    test('rejects empty', () {
      expect(validatePassword(null), 'Password is required');
      expect(validatePassword(''), 'Password is required');
    });

    test('rejects too short', () {
      expect(
        validatePassword('abc1'),
        'Password must be at least 8 characters',
      );
    });

    test('rejects missing number', () {
      expect(
        validatePassword('abcdefgh'),
        'Password must include a letter and a number',
      );
    });

    test('rejects missing letter', () {
      expect(
        validatePassword('12345678'),
        'Password must include a letter and a number',
      );
    });

    test('accepts valid', () {
      expect(validatePassword('abcd1234'), null);
    });
  });

  group('validateLoginPassword', () {
    test('rejects empty', () {
      expect(validateLoginPassword(null), 'Password is required');
      expect(validateLoginPassword(''), 'Password is required');
    });

    test('accepts any non-empty value', () {
      expect(validateLoginPassword('x'), null);
    });
  });

  group('validateConfirmPassword', () {
    test('rejects empty', () {
      expect(validateConfirmPassword(null, 'x'), 'Please confirm your password');
    });

    test('rejects mismatch', () {
      expect(validateConfirmPassword('abc', 'abcd'), 'Passwords do not match');
    });

    test('accepts match', () {
      expect(validateConfirmPassword('abc', 'abc'), null);
    });
  });
}
