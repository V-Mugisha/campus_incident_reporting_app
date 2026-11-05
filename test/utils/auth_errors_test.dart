import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/utils/auth_errors.dart';

void main() {
  test('maps credential errors to a single message', () {
    expect(friendlyAuthError('user-not-found'), 'Incorrect email or password.');
    expect(friendlyAuthError('wrong-password'), 'Incorrect email or password.');
    expect(friendlyAuthError('invalid-credential'), 'Incorrect email or password.');
  });

  test('maps specific codes', () {
    expect(
      friendlyAuthError('email-already-in-use'),
      'An account with this email already exists.',
    );
    expect(friendlyAuthError('weak-password'), 'Please choose a stronger password.');
    expect(
      friendlyAuthError('invalid-email'),
      'Please enter a valid email address.',
    );
    expect(
      friendlyAuthError('network-request-failed'),
      'No internet connection. Please try again.',
    );
    expect(
      friendlyAuthError('too-many-requests'),
      'Too many attempts. Please wait and try again.',
    );
  });

  test('falls back for unknown or missing codes', () {
    expect(
      friendlyAuthError(null),
      'Something went wrong. Please try again.',
    );
    expect(
      friendlyAuthError('some-unknown-code'),
      'Something went wrong. Please try again.',
    );
  });
}
