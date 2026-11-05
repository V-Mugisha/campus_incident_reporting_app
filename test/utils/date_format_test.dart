import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/utils/date_format.dart';

void main() {
  final now = DateTime(2026, 1, 1, 12, 0, 0);

  test('relativeTime formats common durations', () {
    expect(
      relativeTime(now.subtract(const Duration(seconds: 30)), now: now),
      'Just now',
    );
    expect(
      relativeTime(now.subtract(const Duration(minutes: 1)), now: now),
      '1 minute ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(hours: 2)), now: now),
      '2 hours ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(days: 1)), now: now),
      '1 day ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(days: 3)), now: now),
      '3 days ago',
    );
    expect(
      relativeTime(now.subtract(const Duration(days: 14)), now: now),
      '2 weeks ago',
    );
  });

  test('relativeTime treats future dates as just now', () {
    expect(
      relativeTime(now.add(const Duration(hours: 1)), now: now),
      'Just now',
    );
  });

  test('monthYear formats as abbreviated month + year', () {
    expect(monthYear(DateTime(2026, 11)), 'Nov 2026');
    expect(monthYear(DateTime(2026, 1)), 'Jan 2026');
  });
}
