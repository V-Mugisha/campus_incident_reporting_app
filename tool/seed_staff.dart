// One-off dev script: seed the pre-built staff account.
//
// Creates (or reuses) the Auth user and writes the matching `users/{uid}`
// Firestore document with role `staff`, so `AuthProvider.isStaff` routes to
// the staff shell. Idempotent — safe to re-run.
//
// Uses only the Firebase REST APIs over dart:io, so no service account or
// extra dependencies are required. The web API key below is the client key
// already committed in lib/firebase_options.dart.
//
// Usage: dart run tool/seed_staff.dart

import 'dart:convert';
import 'dart:io';

const String apiKey = 'AIzaSyAT-L-GaxIdGCpTcaTmDHew3xZ3GPQDKqI';
const String projectId = 'campus-incident-reportin-3ea44';

const String email = 'staff@gmail.com';
const String password = 'admin123';
const String name = 'Staff Test';

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

Future<Map<String, dynamic>> _signUp() => _request(
      'POST',
      Uri.parse('$authBase:signUp?key=$apiKey'),
      body: {'email': email, 'password': password, 'returnSecureToken': true},
    );

Future<Map<String, dynamic>> _signIn() => _request(
      'POST',
      Uri.parse('$authBase:signInWithPassword?key=$apiKey'),
      body: {'email': email, 'password': password, 'returnSecureToken': true},
    );

Future<void> _writeRoleDoc(String uid, String idToken) async {
  await _request(
    'PATCH',
    Uri.parse('$firestoreBase/users/$uid'),
    headers: {'Authorization': 'Bearer $idToken'},
    body: {
      'fields': {
        'name': {'stringValue': name},
        'email': {'stringValue': email},
        'role': {'stringValue': 'staff'},
        'createdAt': {
          'timestampValue': DateTime.now().toUtc().toIso8601String(),
        },
      },
    },
  );
}

Future<void> main() async {
  String? uid;
  String? idToken;

  try {
    final signUp = await _signUp();
    uid = signUp['localId'] as String?;
    idToken = signUp['idToken'] as String?;
    stdout.writeln('Created Auth user: $email');
  } on HttpException catch (e) {
    if (!e.message.contains('EMAIL_EXISTS')) rethrow;
    final signIn = await _signIn();
    uid = signIn['localId'] as String?;
    idToken = signIn['idToken'] as String?;
    stdout.writeln('Auth user already exists, reusing: $email');
  }

  if (uid == null || idToken == null) {
    stderr.writeln('Failed to resolve a user id/token. Aborting.');
    exit(1);
  }

  await _writeRoleDoc(uid, idToken);
  stdout.writeln('Wrote users/$uid with role = staff');
  stdout.writeln('Done. Sign in with $email / $password in the app.');
}
