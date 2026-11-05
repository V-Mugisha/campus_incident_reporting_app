import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:campus_incident_reporting_app/models/app_user.dart';
import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/models/incident_category.dart';
import 'package:campus_incident_reporting_app/models/user_role.dart';
import 'package:campus_incident_reporting_app/providers/auth_provider.dart';
import 'package:campus_incident_reporting_app/providers/navigation_provider.dart';
import 'package:campus_incident_reporting_app/providers/staff_provider.dart';
import 'package:campus_incident_reporting_app/screens/staff/staff_reports_screen.dart';
import 'package:campus_incident_reporting_app/services/auth_service.dart';
import 'package:campus_incident_reporting_app/services/incident_service.dart';

class _FakeService implements IncidentService {
  final controller = StreamController<List<Incident>>.broadcast();

  @override
  Stream<List<Incident>> streamIncidents() => controller.stream;

  @override
  Stream<List<Incident>> watchMyIncidents(String uid) => const Stream.empty();

  @override
  Stream<Incident?> watchIncident(String id) => const Stream.empty();

  @override
  Future<void> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required String reportedBy,
    required String reportedByName,
    String? location,
  }) async {}

  @override
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
  }) async {}
}

class _FakeAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser> fetchProfile(String uid) async => AppUser(
        id: uid,
        name: '',
        email: '',
        role: UserRole.staff,
      );

  @override
  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

Widget _wrap(StaffProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<StaffProvider>.value(value: provider),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(authService: _FakeAuthService()),
      ),
      ChangeNotifierProvider<NavigationProvider>(
        create: (_) => NavigationProvider(),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: StaffReportsScreen()),
    ),
  );
}

void main() {
  testWidgets('shows empty state when there are no incidents', (tester) async {
    final service = _FakeService();
    final provider = StaffProvider(service: service);
    await tester.pumpWidget(_wrap(provider));

    provider.startListening();
    service.controller.add(const <Incident>[]);
    await tester.pumpAndSettle();

    expect(find.text('Hello 👋'), findsOneWidget);
    expect(find.text('No reports yet'), findsOneWidget);
  });

  testWidgets('shows the reporter name on incident cards', (tester) async {
    final service = _FakeService();
    final provider = StaffProvider(service: service);
    await tester.pumpWidget(_wrap(provider));

    provider.startListening();
    service.controller.add([
      Incident(
        id: '1',
        title: 'Leaky tap',
        category: IncidentCategory.water,
        description: 'Water dripping in the restroom.',
        status: IncidentStatus.submitted,
        reportedBy: 'u1',
        reportedByName: 'Jane Doe',
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Leaky tap'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
  });
}
