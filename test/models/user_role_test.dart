import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/user_role.dart';

void main() {
  test('fromName maps known names', () {
    expect(UserRole.fromName('student'), UserRole.student);
    expect(UserRole.fromName('staff'), UserRole.staff);
  });

  test('fromName defaults to student for unknown or missing values', () {
    expect(UserRole.fromName(null), UserRole.student);
    expect(UserRole.fromName('admin'), UserRole.student);
  });
}
