import '../models/incident.dart';

/// Pure in-memory filter for a student's own reports.
///
/// Search is case-insensitive and matches title, description, location and
/// the category label. Status/category match against the enum name/key.
List<Incident> filterIncidents(
  List<Incident> incidents, {
  String query = '',
  String? status,
  String? category,
}) {
  return incidents.where((incident) {
    if (status != null && incident.status.name != status) return false;
    if (category != null && incident.category.key != category) return false;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      final haystack = '${incident.title} ${incident.description} '
          '${incident.location ?? ''} ${incident.category.label}'
          .toLowerCase();
      if (!haystack.contains(q)) return false;
    }
    return true;
  }).toList();
}
