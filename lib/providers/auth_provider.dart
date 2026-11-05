import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../utils/auth_errors.dart';

/// Holds the current auth state and role for the app.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? FirebaseAuthService() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;

  User? _user;
  UserRole? _role;
  bool _initializing = true;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _user;
  UserRole? get role => _role;
  bool get initializing => _initializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSignedIn => _user != null;
  bool get isStaff => _role == UserRole.staff;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user == null) {
      _role = null;
      _initializing = false;
      notifyListeners();
      return;
    }
    _role = await _authService.fetchRole(user.uid) ?? UserRole.student;
    _initializing = false;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() => _authService.signIn(email: email, password: password));
  }

  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  }) {
    return _guard(
      () => _authService.registerStudent(
        name: name,
        email: email,
        password: password,
        department: department,
      ),
    );
  }

  Future<bool> sendPasswordResetEmail(String email) {
    return _guard(() => _authService.sendPasswordResetEmail(email));
  }

  Future<void> signOut() => _authService.signOut();

  Future<bool> _guard(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = friendlyAuthError(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = friendlyAuthError(null);
      notifyListeners();
      return false;
    }
  }
}
