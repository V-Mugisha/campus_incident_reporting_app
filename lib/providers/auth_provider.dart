import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../utils/auth_errors.dart';

/// Holds the current auth state and profile for the app.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? FirebaseAuthService() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;

  AppUser? _currentUser;
  bool _initializing = true;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get initializing => _initializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSignedIn => _currentUser != null;
  bool get isStaff => _currentUser?.role == UserRole.staff;

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
      _initializing = false;
      notifyListeners();
      return;
    }
    _currentUser = await _authService.fetchProfile(user.uid);
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

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

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
