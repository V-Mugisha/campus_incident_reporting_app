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

  group('studentEmail', () {
    test('rejects empty', () {
      expect(studentEmail(null), 'Email is required');
      expect(studentEmail('   '), 'Email is required');
    });

    test('rejects non-ALU or wrong-shape emails', () {
      const message =
          'Use your ALU student email (@alustudent.com)';
      expect(studentEmail('amuhawenim@alustudent.com'), message);
      expect(studentEmail('1.muhawenim@alustudent.com'), message);
      expect(studentEmail('a.muhawenim@alueducation.com'), message);
      expect(studentEmail('someone@gmail.com'), message);
    });

    test('accepts valid ALU student emails', () {
      expect(studentEmail('a.muhawenim@alustudent.com'), null);
      expect(studentEmail('j.doe@alustudent.com'), null);
      expect(studentEmail('d.student@alustudent.com'), null);
    });
  });

  group('staffEmail', () {
    test('rejects empty', () {
      expect(staffEmail(null), 'Email is required');
    });

    test('rejects non-ALU email', () {
      const message = 'Use your ALU staff email (e.g. name@alueducation.com)';
      expect(staffEmail('bernard@alustudent.com'), message);
      expect(staffEmail('bernard@gmail.com'), message);
    });

    test('accepts valid ALU staff email', () {
      expect(staffEmail('bernard@alueducation.com'), null);
    });
  });

  group('aluEmail', () {
    test('rejects empty', () {
      expect(aluEmail(null), 'Email is required');
    });

    test('rejects non-ALU email', () {
      expect(
        aluEmail('someone@gmail.com'),
        'Use your ALU email (student or staff)',
      );
    });

    test('accepts student and staff emails', () {
      expect(aluEmail('d.student@alustudent.com'), null);
      expect(aluEmail('bernard@alueducation.com'), null);
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

  group('validateTitle', () {
    test('rejects empty', () {
      expect(validateTitle(null), 'Title is required');
      expect(validateTitle('   '), 'Title is required');
    });

    test('rejects too short', () {
      expect(validateTitle('abcd'), 'Title must be at least 5 characters');
    });

    test('rejects too long', () {
      expect(
        validateTitle('a' * 81),
        'Title must be at most 80 characters',
      );
    });

    test('accepts valid', () {
      expect(validateTitle('Broken tap in Block B'), null);
    });
  });

  group('validateDescription', () {
    test('rejects empty', () {
      expect(validateDescription(null), 'Description is required');
    });

    test('rejects too short', () {
      expect(
        validateDescription('short'),
        'Please add a few more details (at least 15 characters)',
      );
    });

    test('rejects too long', () {
      expect(
        validateDescription('a' * 501),
        'Description must be at most 500 characters',
      );
    });

    test('accepts valid', () {
      expect(validateDescription('This is a detailed description.'), null);
    });
  });

  group('validateCategory', () {
    test('rejects null or empty', () {
      expect(validateCategory(null), 'Please select a category');
      expect(validateCategory(''), 'Please select a category');
    });

    test('accepts a value', () {
      expect(validateCategory('water'), null);
    });
  });

  group('validateLocation', () {
    test('rejects null or empty', () {
      expect(validateLocation(null), 'Please select a location');
      expect(validateLocation(''), 'Please select a location');
    });

    test('accepts a value', () {
      expect(validateLocation('Library'), null);
    });
  });

  group('validateSpecifyLocation', () {
    test('rejects empty', () {
      expect(validateSpecifyLocation(null), 'Please specify a location');
      expect(validateSpecifyLocation('   '), 'Please specify a location');
    });

    test('rejects too short', () {
      expect(
        validateSpecifyLocation('ab'),
        'Location must be at least 3 characters',
      );
    });

    test('accepts valid', () {
      expect(validateSpecifyLocation('Roof'), null);
    });
  });
}
