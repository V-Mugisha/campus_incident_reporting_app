import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar.dart';
import '../../widgets/floating_nav_bar.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'report_incident_screen.dart';

/// Root shell for logged-in students: an IndexedStack of tabs plus the
/// floating navigation bar. Owns the incident stream lifecycle.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.id;
    if (uid != null) {
      context.read<IncidentProvider>().startListening(uid);
    }
  }

  @override
  void dispose() {
    context.read<IncidentProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return PopScope(
      canPop: nav.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && nav.currentIndex != 0) {
          nav.setIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: IndexedStack(
          index: nav.currentIndex,
          children: const [
            HomeScreen(),
            MyReportsScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: nav.currentIndex,
          onSelect: nav.setIndex,
          onReport: () async {
            final submitted = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => const ReportIncidentScreen(),
              ),
            );
            if (submitted == true && context.mounted) {
              showSuccessSnackBar(context, 'Report submitted successfully');
            }
          },
        ),
      ),
    );
  }
}
