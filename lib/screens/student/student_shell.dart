import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar.dart';
import '../../widgets/floating_nav_bar.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'report_incident_screen.dart';
import 'reports_placeholder_screen.dart';

/// Root shell for logged-in students: an IndexedStack of tabs plus the
/// floating navigation bar.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

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
            ReportsPlaceholderScreen(),
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
