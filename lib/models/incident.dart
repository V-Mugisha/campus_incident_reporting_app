import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_category.dart';

/// Lifecycle of an incident report.
enum IncidentStatus {
  submitted('Submitted'),
  inProgress('In progress'),
  resolved('Resolved');

  const IncidentStatus(this.label);

  final String label;

  static IncidentStatus fromName(String? name) {
    return IncidentStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => IncidentStatus.submitted,
    );
  }
}

/// An incident report submitted by a student.
class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.reportedBy,
    required this.createdAt,
    this.location,
    this.imageUrl,
    this.updatedAt,
  });

  final String id;
  final String title;
  final IncidentCategory category;
  final String description;
  final String? location;
  final String? imageUrl;
  final IncidentStatus status;
  final String reportedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Incident.fromFirestore(String id, Map<String, dynamic> data) {
    return Incident(
      id: id,
      title: data['title'] as String? ?? '',
      category: IncidentCategory.fromKey(data['category'] as String?),
      description: data['description'] as String? ?? '',
      location: data['location'] as String?,
      imageUrl: data['imageUrl'] as String?,
      status: IncidentStatus.fromName(data['status'] as String?),
      reportedBy: data['reportedBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category.key,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'status': status.name,
      'reportedBy': reportedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}
