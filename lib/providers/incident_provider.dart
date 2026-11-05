import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../services/incident_service.dart';

/// Holds the list of incidents and exposes submit/update operations.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider({IncidentService? service})
      : _service = service ?? IncidentService();

  final IncidentService _service;

  List<Incident> _incidents = [];
  StreamSubscription<List<Incident>>? _subscription;
  bool _loading = false;
  String? _error;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Incident> get incidents => _incidents;
  bool get loading => _loading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void load() {
    _subscription?.cancel();
    _loading = true;
    _error = null;
    notifyListeners();

    _subscription = _service.streamIncidents().listen(
      (list) {
        _incidents = list;
        _loading = false;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required AppUser reporter,
    String? location,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.submitIncident(
        category: category,
        title: title,
        description: description,
        location: location,
        reportedBy: reporter.id,
        reportedByName: reporter.name,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      _errorMessage = "Couldn't submit your report. Please try again.";
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    _error = null;
    try {
      await _service.updateStatus(id, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
