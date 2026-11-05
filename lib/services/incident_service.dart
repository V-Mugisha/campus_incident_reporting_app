import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/incident.dart';

/// Wraps Cloud Firestore and Firebase Storage for incident reports.
class IncidentService {
  IncidentService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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

  Future<void> submitIncident({
    required String title,
    required IncidentCategory category,
    required String description,
    required String reporterId,
    File? photo,
  }) async {
    String? photoUrl;
    if (photo != null) {
      photoUrl = await _uploadPhoto(photo, reporterId);
    }

    await _firestore.collection('incidents').add({
      'title': title,
      'category': category.name,
      'description': description,
      'photoUrl': photoUrl,
      'status': IncidentStatus.submitted.name,
      'reporterId': reporterId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    await _firestore.collection('incidents').doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _uploadPhoto(File photo, String reporterId) async {
    final name =
        'incident_photos/${reporterId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref(name);
    await ref.putFile(photo);
    return ref.getDownloadURL();
  }
}
