import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/widgets/status_chip.dart';

void main() {
  testWidgets('StatusChip maps status to the correct label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              StatusChip(status: IncidentStatus.submitted),
              StatusChip(status: IncidentStatus.inProgress),
              StatusChip(status: IncidentStatus.resolved),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });
}
