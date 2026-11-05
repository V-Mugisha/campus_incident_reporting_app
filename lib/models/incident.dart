import 'package:cloud_firestore/cloud_firestore.dart';

/// Categories a student can choose when filing an incident report.
enum IncidentCategory {
  brokenFacility('Broken facility'),
  waterShortage('Water shortage'),
  electricityOutage('Electricity outage'),
  damagedFurniture('Damaged furniture'),
  sanitation('Sanitation'),
  safetyConcern('Safety concern'),
  other('Other');

  const IncidentCategory(this.label);

  final String label;

  static IncidentCategory fromName(String? name) {
    return IncidentCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => IncidentCategory.other,
    );
  }
}

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
    required this.reporterId,
    required this.createdAt,
    this.photoUrl,
    this.updatedAt,
  });

  final String id;
  final String title;
  final IncidentCategory category;
  final String description;
  final String? photoUrl;
  final IncidentStatus status;
  final String reporterId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Incident.fromFirestore(String id, Map<String, dynamic> data) {
    return Incident(
      id: id,
      title: data['title'] as String? ?? '',
      category: IncidentCategory.fromName(data['category'] as String?),
      description: data['description'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      status: IncidentStatus.fromName(data['status'] as String?),
      reporterId: data['reporterId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category.name,
      'description': description,
      'photoUrl': photoUrl,
      'status': status.name,
      'reporterId': reporterId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}
