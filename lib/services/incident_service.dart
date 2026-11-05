import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';

/// Contract for incident persistence so providers and tests depend on the
/// interface, not on Firestore directly.
abstract class IncidentService {
  /// Streams all incident reports, newest first (staff review queue).
  Stream<List<Incident>> streamIncidents();

  /// Streams the signed-in student's own reports, newest first.
  Stream<List<Incident>> watchMyIncidents(String uid);

  /// Streams a single incident by id.
  Stream<Incident?> watchIncident(String id);

  Future<void> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required String reportedBy,
    required String reportedByName,
    String? location,
  });

  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
  });
}

/// Firestore-backed implementation of [IncidentService].
class FirebaseIncidentService implements IncidentService {
  FirebaseIncidentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
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

  /// Requires a composite index on `reportedBy` (asc) + `createdAt` (desc).
  @override
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

  @override
  Stream<Incident?> watchIncident(String id) {
    return _firestore.collection('incidents').doc(id).snapshots().map(
          (doc) =>
              doc.exists ? Incident.fromFirestore(doc.id, doc.data()!) : null,
        );
  }

  @override
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

  @override
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
  }) async {
    await _firestore.collection('incidents').doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status.name,
          'changedBy': changedBy,
          'timestamp': Timestamp.now(),
        },
      ]),
    });
  }
}
