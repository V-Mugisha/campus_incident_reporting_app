import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/incident.dart';
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

  List<Incident> get incidents => _incidents;
  bool get loading => _loading;
  String? get error => _error;

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

  Future<void> submit({
    required String title,
    required IncidentCategory category,
    required String description,
    required String reporterId,
    File? photo,
  }) async {
    _error = null;
    try {
      await _service.submitIncident(
        title: title,
        category: category,
        description: description,
        reporterId: reporterId,
        photo: photo,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
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
