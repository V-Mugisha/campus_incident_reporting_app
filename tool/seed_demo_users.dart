// One-off dev script: seed the two demo accounts used for grading/demos.
//
// Creates (or reuses) each Auth user and writes the matching `users/{uid}`
// Firestore document so role-based access works in the app.
//
//   Staff  -> staff@alueducation.com / Campus123   (role: staff,   name: Staff Test)
//   Student-> m.victor@alustudent.com / Campus123  (role: student, name: Test Student)
//
// IMPORTANT: run this BEFORE deploying `firestore.rules` (or while Firestore
// has test-mode / no rules). The deployed rules allow users to create only a
// `student` profile and forbid updating an existing one, so a staff profile
// cannot be written by this script once those rules are live.
//
// Uses only the Firebase REST APIs over dart:io, so no service account or
// extra dependencies are required. The web API key below is the client key
// already committed in lib/firebase_options.dart.
//
// Usage: dart run tool/seed_demo_users.dart

import 'dart:convert';
import 'dart:io';

const String apiKey = 'AIzaSyAT-L-GaxIdGCpTcaTmDHew3xZ3GPQDKqI';
const String projectId = 'campus-incident-reportin-3ea44';

const String authBase = 'https://identitytoolkit.googleapis.com/v1/accounts';
const String firestoreBase =
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

Future<Map<String, dynamic>> _request(
  String method,
  Uri uri, {
  Map<String, dynamic>? body,
  Map<String, String>? headers,
}) async {
  final client = HttpClient();
  try {
    final req = await client.openUrl(method, uri);
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    headers?.forEach(req.headers.set);
    if (body != null) {
      req.write(jsonEncode(body));
    }
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
    if (res.statusCode >= 400) {
      throw HttpException(
        'HTTP ${res.statusCode}: ${decoded['error']?['message'] ?? text}',
      );
    }
    return decoded as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

Future<(String, String)> _resolveUser(String email, String password) async {
  try {
    final signUp = await _request(
      'POST',
      Uri.parse('$authBase:signUp?key=$apiKey'),
      body: {'email': email, 'password': password, 'returnSecureToken': true},
    );
    stdout.writeln('Created Auth user: $email');
    return (signUp['localId'] as String, signUp['idToken'] as String);
  } on HttpException catch (e) {
    if (!e.message.contains('EMAIL_EXISTS')) rethrow;
    final signIn = await _request(
      'POST',
      Uri.parse('$authBase:signInWithPassword?key=$apiKey'),
      body: {'email': email, 'password': password, 'returnSecureToken': true},
    );
    stdout.writeln('Auth user already exists, reusing: $email');
    return (signIn['localId'] as String, signIn['idToken'] as String);
  }
}

Future<void> _writeProfile(
  String uid,
  String idToken,
  String email,
  String name,
  String role,
) async {
  await _request(
    'PATCH',
    Uri.parse('$firestoreBase/users/$uid'),
    headers: {'Authorization': 'Bearer $idToken'},
    body: {
      'fields': {
        'name': {'stringValue': name},
        'email': {'stringValue': email},
        'role': {'stringValue': role},
        'createdAt': {
          'timestampValue': DateTime.now().toUtc().toIso8601String(),
        },
      },
    },
  );
  stdout.writeln('Wrote users/$uid with role = $role');
}

Future<void> main() async {
  final staff = await _resolveUser('staff@alueducation.com', 'Campus123');
  await _writeProfile(
    staff.$1,
    staff.$2,
    'staff@alueducation.com',
    'Staff Test',
    'staff',
  );

  final student =
      await _resolveUser('m.victor@alustudent.com', 'Campus123');
  await _writeProfile(
    student.$1,
    student.$2,
    'm.victor@alustudent.com',
    'Test Student',
    'student',
  );

  stdout.writeln('Done. Both demo accounts are ready.');
}
