import 'package:flutter/material.dart';

/// Incident categories. The [key] is what gets stored in Firestore, never
/// the label. Shared by the report form, filters, and cards.
enum IncidentCategory {
  facilities('facilities', 'Facilities', Icons.apartment_rounded),
  water('water', 'Water', Icons.water_drop_rounded),
  electricity('electricity', 'Electricity', Icons.bolt_rounded),
  safety('safety', 'Safety', Icons.shield_rounded),
  sanitation('sanitation', 'Sanitation', Icons.delete_rounded);

  const IncidentCategory(this.key, this.label, this.icon);

  final String key;
  final String label;
  final IconData icon;

  static IncidentCategory fromKey(String? key) {
    return IncidentCategory.values.firstWhere(
      (category) => category.key == key,
      orElse: () => IncidentCategory.facilities,
    );
  }
}
