import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident.dart';

void main() {
  group('Incident.fromFirestore', () {
    test('parses a full document', () {
      final now = DateTime(2026, 1, 2, 3, 4, 5);
      final updated = DateTime(2026, 1, 3);

      final incident = Incident.fromFirestore('id1', {
        'title': 'Broken tap',
        'category': 'waterShortage',
        'description': 'No water in block B',
        'photoUrl': 'https://example.com/photo.jpg',
        'status': 'inProgress',
        'reporterId': 'user1',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(updated),
      });

      expect(incident.id, 'id1');
      expect(incident.title, 'Broken tap');
      expect(incident.category, IncidentCategory.waterShortage);
      expect(incident.description, 'No water in block B');
      expect(incident.photoUrl, 'https://example.com/photo.jpg');
      expect(incident.status, IncidentStatus.inProgress);
      expect(incident.reporterId, 'user1');
      expect(incident.createdAt, now);
      expect(incident.updatedAt, updated);
    });

    test('defaults missing or unknown fields', () {
      final incident = Incident.fromFirestore('id2', {});

      expect(incident.title, '');
      expect(incident.category, IncidentCategory.other);
      expect(incident.status, IncidentStatus.submitted);
      expect(incident.photoUrl, isNull);
      expect(incident.updatedAt, isNull);
    });
  });

  test('toFirestore writes category and status by name', () {
    final incident = Incident(
      id: 'id3',
      title: 't',
      category: IncidentCategory.safetyConcern,
      description: 'd',
      status: IncidentStatus.resolved,
      reporterId: 'u',
      createdAt: DateTime(2026),
    );

    final map = incident.toFirestore();

    expect(map['title'], 't');
    expect(map['category'], 'safetyConcern');
    expect(map['status'], 'resolved');
    expect(map['reporterId'], 'u');
  });
}
