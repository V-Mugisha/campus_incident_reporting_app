import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../services/incident_service.dart';
import '../utils/incident_filters.dart';

/// Holds the signed-in student's reports plus search/filter state.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider({IncidentService? service})
      : _service = service ?? FirebaseIncidentService();

  final IncidentService _service;

  List<Incident> _allMine = [];
  StreamSubscription<List<Incident>>? _subscription;
  bool _loading = false;
  String? _errorMessage;
  bool _isSubmitting = false;
  String? _submitError;
  bool _isDeleting = false;
  String? _deleteError;

  String _searchQuery = '';
  String? _statusFilter;
  String? _categoryFilter;

  List<Incident> get allMine => _allMine;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get isDeleting => _isDeleting;
  String? get deleteError => _deleteError;

  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _statusFilter != null ||
      _categoryFilter != null;

  List<Incident> get filteredIncidents => filterIncidents(
        _allMine,
        query: _searchQuery,
        status: _statusFilter,
        category: _categoryFilter,
      );

  int get totalCount => _allMine.length;
  int get submittedCount => _countBy(IncidentStatus.submitted);
  int get inProgressCount => _countBy(IncidentStatus.inProgress);
  int get resolvedCount => _countBy(IncidentStatus.resolved);

  int _countBy(IncidentStatus status) =>
      _allMine.where((i) => i.status == status).length;

  void setSearch(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    if (!hasActiveFilters) return;
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  void startListening(String uid) {
    _subscription?.cancel();
    _subscription = null;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _service.watchMyIncidents(uid).listen(
      (list) {
        _allMine = list;
        _loading = false;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('watchMyIncidents error: $e');
        _loading = false;
        _errorMessage = "Couldn't load your reports.";
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _allMine = [];
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    _loading = false;
    _errorMessage = null;
  }

  /// Live single-incident stream used by the details screen.
  Stream<Incident?> watchIncident(String id) => _service.watchIncident(id);

  Future<bool> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required AppUser reporter,
    String? location,
  }) async {
    _isSubmitting = true;
    _submitError = null;
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
      _submitError = "Couldn't submit your report. Please try again.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateIncident({
    required String id,
    required IncidentCategory category,
    required String title,
    required String description,
    String? location,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _service.updateIncident(
        id: id,
        category: category,
        title: title,
        description: description,
        location: location,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      _submitError = "Couldn't update your report. Please try again.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteIncident(String id) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _service.deleteIncident(id);
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isDeleting = false;
      _deleteError = "Couldn't delete your report. Please try again.";
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
