import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/incident_category.dart';

void main() {
  test('fromKey maps known keys', () {
    expect(IncidentCategory.fromKey('water'), IncidentCategory.water);
    expect(IncidentCategory.fromKey('safety'), IncidentCategory.safety);
    expect(IncidentCategory.fromKey('sanitation'), IncidentCategory.sanitation);
  });

  test('fromKey defaults to facilities for unknown or missing keys', () {
    expect(IncidentCategory.fromKey(null), IncidentCategory.facilities);
    expect(IncidentCategory.fromKey('nonsense'), IncidentCategory.facilities);
  });

  test('every category has a key, label and icon', () {
    for (final category in IncidentCategory.values) {
      expect(category.key, isNotEmpty);
      expect(category.label, isNotEmpty);
      expect(category.icon, isA<IconData>());
    }
  });
}
