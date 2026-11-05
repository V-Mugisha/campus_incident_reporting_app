import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/models/incident_category.dart';
import 'package:campus_incident_reporting_app/utils/incident_filters.dart';

Incident _incident(
  String id, {
  IncidentCategory category = IncidentCategory.water,
  IncidentStatus status = IncidentStatus.submitted,
  String title = 'x',
  String description = 'd',
  String? location,
}) {
  return Incident(
    id: id,
    title: title,
    category: category,
    description: description,
    status: status,
    reportedBy: 'u',
    createdAt: DateTime(2026),
    location: location,
  );
}

void main() {
  final incidents = [
    _incident(
      '1',
      title: 'Water shortage',
      category: IncidentCategory.water,
      status: IncidentStatus.submitted,
      location: 'Block A',
    ),
    _incident(
      '2',
      title: 'Broken projector',
      category: IncidentCategory.facilities,
      status: IncidentStatus.inProgress,
      location: 'Room 204',
    ),
    _incident(
      '3',
      title: 'Overflowing bin',
      category: IncidentCategory.sanitation,
      status: IncidentStatus.resolved,
    ),
  ];

  test('search matches title case-insensitively', () {
    final result = filterIncidents(incidents, query: 'WATER');
    expect(result.length, 1);
    expect(result.first.id, '1');
  });

  test('search matches category label', () {
    final result = filterIncidents(incidents, query: 'facilities');
    expect(result.length, 1);
    expect(result.first.id, '2');
  });

  test('search matches location', () {
    final result = filterIncidents(incidents, query: '204');
    expect(result.length, 1);
    expect(result.first.id, '2');
  });

  test('status filter', () {
    final result =
        filterIncidents(incidents, status: IncidentStatus.resolved.name);
    expect(result.length, 1);
    expect(result.first.id, '3');
  });

  test('category filter', () {
    final result =
        filterIncidents(incidents, category: IncidentCategory.water.key);
    expect(result.length, 1);
    expect(result.first.id, '1');
  });

  test('combined filters', () {
    final result = filterIncidents(
      incidents,
      query: 'bin',
      status: IncidentStatus.resolved.name,
    );
    expect(result.length, 1);
    expect(result.first.id, '3');
  });
}
