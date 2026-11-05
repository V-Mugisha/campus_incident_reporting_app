import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
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

  /// Loads the full profile for a user id from `users/{uid}`.
  Future<AppUser> fetchProfile(String uid);
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
  Future<AppUser> fetchProfile(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    final authUser = _auth.currentUser;

    if (!doc.exists) {
      final displayName = authUser?.displayName;
      final name = (displayName != null && displayName.isNotEmpty)
          ? displayName
          : 'Test Student';
      final email = authUser?.email ?? '';
      await docRef.set({
        'name': name,
        'email': email,
        'role': UserRole.student.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return AppUser(
        id: uid,
        name: name,
        email: email,
        role: UserRole.student,
        createdAt: DateTime.now(),
      );
    }

    final data = doc.data();
    return AppUser(
      id: uid,
      name: data?['name'] as String? ?? authUser?.displayName ?? '',
      email: data?['email'] as String? ?? authUser?.email ?? '',
      role: UserRole.fromName(data?['role'] as String?),
      department: data?['department'] as String?,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
