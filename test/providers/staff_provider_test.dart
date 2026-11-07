import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/models/incident_category.dart';
import 'package:campus_incident_reporting_app/providers/staff_provider.dart';
import 'package:campus_incident_reporting_app/services/incident_service.dart';

class FakeIncidentService implements IncidentService {
  final controller = StreamController<List<Incident>>.broadcast();

  String? updatedId;
  IncidentStatus? updatedStatus;
  String? updatedChangedBy;

  @override
  Stream<List<Incident>> streamIncidents() => controller.stream;

  @override
  Stream<List<Incident>> watchMyIncidents(String uid) => const Stream.empty();

  @override
  Stream<Incident?> watchIncident(String id) => const Stream.empty();

  @override
  Future<void> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required String reportedBy,
    required String reportedByName,
    String? location,
  }) async {}

  @override
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
  }) async {
    updatedId = id;
    updatedStatus = status;
    updatedChangedBy = changedBy;
  }

  @override
  Future<void> updateIncident({
    required String id,
    required IncidentCategory category,
    required String title,
    required String description,
    String? location,
  }) async {}

  @override
  Future<void> deleteIncident(String id) async {}
}

Incident _incident(
  String id, {
  IncidentStatus status = IncidentStatus.submitted,
  String title = 'Broken light',
}) {
  return Incident(
    id: id,
    title: title,
    category: IncidentCategory.safety,
    description: 'desc',
    status: status,
    reportedBy: 'user-$id',
    reportedByName: 'Reporter $id',
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late FakeIncidentService service;
  late StaffProvider provider;

  setUp(() {
    service = FakeIncidentService();
    provider = StaffProvider(service: service);
  });

  tearDown(() {
    provider.stopListening();
    service.controller.close();
  });

  test('startListening loads all incidents and computes counts', () async {
    provider.startListening();
    service.controller.add([
      _incident('1'),
      _incident('2', status: IncidentStatus.inProgress),
      _incident('3', status: IncidentStatus.resolved),
    ]);
    await pumpEventQueue();

    expect(provider.totalCount, 3);
    expect(provider.submittedCount, 1);
    expect(provider.inProgressCount, 1);
    expect(provider.resolvedCount, 1);
  });

  test('filteredIncidents respects the status filter', () async {
    provider.startListening();
    service.controller.add([
      _incident('1'),
      _incident('2', status: IncidentStatus.resolved),
    ]);
    await pumpEventQueue();

    provider.setStatusFilter(IncidentStatus.resolved.name);
    expect(provider.filteredIncidents.length, 1);
    expect(provider.filteredIncidents.single.id, '2');
  });

  test('updateStatus delegates to the service with the changedBy name', () async {
    final ok = await provider.updateStatus(
      id: 'abc',
      status: IncidentStatus.inProgress,
      changedBy: 'Staff Test',
    );

    expect(ok, isTrue);
    expect(service.updatedId, 'abc');
    expect(service.updatedStatus, IncidentStatus.inProgress);
    expect(service.updatedChangedBy, 'Staff Test');
  });
}
