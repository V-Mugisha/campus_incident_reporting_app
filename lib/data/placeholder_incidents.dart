import '../models/incident.dart';
import '../models/incident_category.dart';

// TODO: replace with IncidentProvider (real Firestore data).

class PlaceholderSummary {
  const PlaceholderSummary({
    required this.myReports,
    required this.inProgress,
    required this.resolved,
    required this.submitted,
  });

  final int myReports;
  final int inProgress;
  final int resolved;
  final int submitted;
}

final List<Incident> placeholderIncidents = [
  Incident(
    id: 'p1',
    title: 'Water shortage',
    category: IncidentCategory.water,
    description: 'No water in Block B restrooms.',
    status: IncidentStatus.inProgress,
    reportedBy: 'me',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Incident(
    id: 'p2',
    title: 'Broken classroom projector',
    category: IncidentCategory.facilities,
    description: 'Projector in Room 204 will not turn on.',
    status: IncidentStatus.submitted,
    reportedBy: 'me',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  Incident(
    id: 'p3',
    title: 'Overflowing bin',
    category: IncidentCategory.sanitation,
    description: 'Bins near the cafeteria are full.',
    status: IncidentStatus.resolved,
    reportedBy: 'me',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

final PlaceholderSummary placeholderSummary = const PlaceholderSummary(
  myReports: 3,
  inProgress: 1,
  resolved: 1,
  submitted: 1,
);
