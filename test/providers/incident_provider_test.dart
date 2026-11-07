import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/models/incident_category.dart';
import 'package:campus_incident_reporting_app/providers/incident_provider.dart';
import 'package:campus_incident_reporting_app/services/incident_service.dart';

class _FakeService implements IncidentService {
  String? updatedId;
  IncidentCategory? updatedCategory;
  String? updatedTitle;
  String? updatedDescription;
  String? updatedLocation;
  String? deletedId;

  @override
  Stream<List<Incident>> streamIncidents() => const Stream.empty();

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
  }) async {}

  @override
  Future<void> updateIncident({
    required String id,
    required IncidentCategory category,
    required String title,
    required String description,
    String? location,
  }) async {
    updatedId = id;
    updatedCategory = category;
    updatedTitle = title;
    updatedDescription = description;
    updatedLocation = location;
  }

  @override
  Future<void> deleteIncident(String id) async {
    deletedId = id;
  }
}

void main() {
  test('updateIncident delegates to the service', () async {
    final service = _FakeService();
    final provider = IncidentProvider(service: service);

    final ok = await provider.updateIncident(
      id: 'inc1',
      category: IncidentCategory.water,
      title: 'Leaky tap',
      description: 'Water is dripping in Block B.',
      location: 'Library',
    );

    expect(ok, isTrue);
    expect(service.updatedId, 'inc1');
    expect(service.updatedCategory, IncidentCategory.water);
    expect(service.updatedTitle, 'Leaky tap');
    expect(service.updatedDescription, 'Water is dripping in Block B.');
    expect(service.updatedLocation, 'Library');
  });

  test('deleteIncident delegates to the service', () async {
    final service = _FakeService();
    final provider = IncidentProvider(service: service);

    final ok = await provider.deleteIncident('inc2');

    expect(ok, isTrue);
    expect(service.deletedId, 'inc2');
  });
}
