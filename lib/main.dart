import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/staff/staff_placeholder_screen.dart';
import 'screens/student/student_shell.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CampusReportApp());
}

class CampusReportApp extends StatelessWidget {
  const CampusReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final String stateKey;
    final Widget screen;
    if (auth.initializing) {
      stateKey = 'loading';
      screen = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (!auth.isSignedIn) {
      stateKey = 'login';
      screen = const LoginScreen();
    } else if (auth.isStaff) {
      stateKey = 'staff';
      screen = const StaffPlaceholderScreen();
    } else {
      stateKey = 'student';
      screen = const StudentShell();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(stateKey), child: screen),
    );
  }
}
