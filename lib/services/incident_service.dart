import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';

/// Wraps Cloud Firestore for incident reports.
class IncidentService {
  IncidentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Incident>> streamIncidents() {
    return _firestore
        .collection('incidents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Incident.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Streams the signed-in student's own reports, newest first.
  ///
  /// Requires a composite index on `reportedBy` (asc) + `createdAt` (desc).
  Stream<List<Incident>> watchMyIncidents(String uid) {
    return _firestore
        .collection('incidents')
        .where('reportedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Incident.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<Incident?> watchIncident(String id) {
    return _firestore.collection('incidents').doc(id).snapshots().map(
          (doc) =>
              doc.exists ? Incident.fromFirestore(doc.id, doc.data()!) : null,
        );
  }

  Future<void> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required String reportedBy,
    required String reportedByName,
    String? location,
  }) async {
    await _firestore.collection('incidents').add({
      'title': title,
      'category': category.key,
      'description': description,
      'location': location,
      'imageUrl': null,
      'status': IncidentStatus.submitted.name,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': [
        {
          'status': IncidentStatus.submitted.name,
          'changedBy': reportedBy,
          'timestamp': Timestamp.now(),
        },
      ],
    });
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    await _firestore.collection('incidents').doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
