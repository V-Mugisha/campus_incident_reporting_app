import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SmokeTestScreen extends StatefulWidget {
  const SmokeTestScreen({super.key});

  @override
  State<SmokeTestScreen> createState() => _SmokeTestScreenState();
}

class _SmokeTestScreenState extends State<SmokeTestScreen> {
  String _status = 'Not started';
  bool _running = false;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _status = 'Running...';
    });

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    const email = 'smoketest@example.com';
    const password = 'smoketest123';

    try {
      User user;
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = cred.user!;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          user = cred.user!;
        } else {
          rethrow;
        }
      }

      final docRef = firestore.collection('smoke_test').doc(user.uid);
      await docRef.set({
        'message': 'hello from smoke test',
        'at': FieldValue.serverTimestamp(),
      });

      final snap = await docRef.get();
      final message = snap.data()?['message'] as String?;

      if (!mounted) return;
      debugPrint('SMOKE OK uid=${user.uid} message=$message');
      setState(() {
        _running = false;
        _status = 'OK\nuid: ${user.uid}\nmessage: $message';
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('SMOKE FAILED: $e');
      setState(() {
        _running = false;
        _status = 'FAILED: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smoke Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _running ? null : _run,
              child: Text(_running ? 'Running...' : 'Run smoke test'),
            ),
            const SizedBox(height: 24),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
