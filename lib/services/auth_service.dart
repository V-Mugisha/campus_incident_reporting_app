import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_role.dart';

/// Contract for authentication so screens and tests depend on the interface,
/// not on Firebase directly.
abstract class AuthService {
  Stream<User?> get authStateChanges;

  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserRole?> fetchRole(String uid);
}

/// Firebase-backed implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) return;

    await user.updateDisplayName(name);
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'department': department,
      // Role is always student here; never taken from user input.
      'role': UserRole.student.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserRole?> fetchRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserRole.fromName(doc.data()?['role'] as String?);
  }
}
