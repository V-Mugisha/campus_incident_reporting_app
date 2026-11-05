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

/// A single entry in an incident's status history.
class StatusEntry {
  const StatusEntry({
    required this.status,
    required this.changedBy,
    required this.timestamp,
  });

  final IncidentStatus status;
  final String changedBy;
  final DateTime timestamp;
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
    this.reportedByName,
    this.statusHistory = const [],
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
  final String? reportedByName;
  final List<StatusEntry> statusHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Display name of the reporter, falling back to 'Unknown' when missing.
  String get reporterLabel {
    final name = reportedByName;
    return (name == null || name.trim().isEmpty) ? 'Unknown' : name.trim();
  }

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
      reportedByName: data['reportedByName'] as String?,
      statusHistory: (data['statusHistory'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .map(
                (e) => StatusEntry(
                  status: IncidentStatus.fromName(e['status'] as String?),
                  changedBy: e['changedBy'] as String? ?? '',
                  timestamp:
                      (e['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                ),
              )
              .toList() ??
          const [],
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
      'reportedByName': reportedByName,
      'statusHistory': statusHistory
          .map(
            (e) => {
              'status': e.status.name,
              'changedBy': e.changedBy,
              'timestamp': Timestamp.fromDate(e.timestamp),
            },
          )
          .toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}
