import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';
import '../utils/incident_filters.dart';

/// Holds all incident reports for staff review plus search/filter state.
class StaffProvider extends ChangeNotifier {
  StaffProvider({IncidentService? service})
      : _service = service ?? FirebaseIncidentService();

  final IncidentService _service;

  List<Incident> _all = [];
  StreamSubscription<List<Incident>>? _subscription;
  bool _loading = false;
  String? _errorMessage;
  bool _isUpdating = false;
  String? _updateError;

  String _searchQuery = '';
  String? _statusFilter;
  String? _categoryFilter;

  List<Incident> get all => _all;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  bool get isUpdating => _isUpdating;
  String? get updateError => _updateError;

  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _statusFilter != null ||
      _categoryFilter != null;

  List<Incident> get filteredIncidents => filterIncidents(
        _all,
        query: _searchQuery,
        status: _statusFilter,
        category: _categoryFilter,
      );

  int get totalCount => _all.length;
  int get submittedCount => _countBy(IncidentStatus.submitted);
  int get inProgressCount => _countBy(IncidentStatus.inProgress);
  int get resolvedCount => _countBy(IncidentStatus.resolved);

  int _countBy(IncidentStatus status) =>
      _all.where((i) => i.status == status).length;

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

  void startListening() {
    _subscription?.cancel();
    _subscription = null;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _service.streamIncidents().listen(
      (list) {
        _all = list;
        _loading = false;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('streamIncidents error: $e');
        _loading = false;
        _errorMessage = "Couldn't load incidents.";
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _all = [];
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    _loading = false;
    _errorMessage = null;
  }

  Future<bool> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
  }) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _service.updateStatus(
        id: id,
        status: status,
        changedBy: changedBy,
      );
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isUpdating = false;
      _updateError = "Couldn't update the status. Please try again.";
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
