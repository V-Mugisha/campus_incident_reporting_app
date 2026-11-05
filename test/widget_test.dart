// Basic widget test for the Campus Incident Reporting app.

import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/main.dart';

void main() {
  testWidgets('Home screen renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusReportApp());

    expect(find.text('Campus Incident Reporting'), findsWidgets);
  });
}
