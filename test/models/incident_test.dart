import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/models/incident_category.dart';

void main() {
  group('Incident.fromFirestore', () {
    test('parses a full document', () {
      final now = DateTime(2026, 1, 2, 3, 4, 5);
      final updated = DateTime(2026, 1, 3);

      final incident = Incident.fromFirestore('id1', {
        'title': 'Broken tap',
        'category': 'water',
        'description': 'No water in block B',
        'location': 'Block B',
        'imageUrl': 'https://example.com/photo.jpg',
        'status': 'inProgress',
        'reportedBy': 'user1',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(updated),
      });

      expect(incident.id, 'id1');
      expect(incident.title, 'Broken tap');
      expect(incident.category, IncidentCategory.water);
      expect(incident.description, 'No water in block B');
      expect(incident.location, 'Block B');
      expect(incident.imageUrl, 'https://example.com/photo.jpg');
      expect(incident.status, IncidentStatus.inProgress);
      expect(incident.reportedBy, 'user1');
      expect(incident.createdAt, now);
      expect(incident.updatedAt, updated);
    });

    test('defaults missing or unknown fields', () {
      final incident = Incident.fromFirestore('id2', {});

      expect(incident.title, '');
      expect(incident.category, IncidentCategory.facilities);
      expect(incident.status, IncidentStatus.submitted);
      expect(incident.location, isNull);
      expect(incident.imageUrl, isNull);
      expect(incident.updatedAt, isNull);
    });
  });

  test('toFirestore writes category key and fields', () {
    final incident = Incident(
      id: 'id3',
      title: 't',
      category: IncidentCategory.safety,
      description: 'd',
      status: IncidentStatus.resolved,
      reportedBy: 'u',
      createdAt: DateTime(2026),
    );

    final map = incident.toFirestore();

    expect(map['title'], 't');
    expect(map['category'], 'safety');
    expect(map['status'], 'resolved');
    expect(map['reportedBy'], 'u');
  });
}
