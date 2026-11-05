import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:campus_incident_reporting_app/models/user_role.dart';
import 'package:campus_incident_reporting_app/providers/auth_provider.dart';
import 'package:campus_incident_reporting_app/screens/auth/login_screen.dart';
import 'package:campus_incident_reporting_app/screens/auth/signup_screen.dart';
import 'package:campus_incident_reporting_app/services/auth_service.dart';
import 'package:campus_incident_reporting_app/widgets/primary_button.dart';

class FakeAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<UserRole?> fetchRole(String uid) async => null;

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

Widget _wrap(Widget child) {
  return ChangeNotifierProvider<AuthProvider>(
    create: (_) => AuthProvider(authService: FakeAuthService()),
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('login shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('signup shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(_wrap(const SignupScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });
}
