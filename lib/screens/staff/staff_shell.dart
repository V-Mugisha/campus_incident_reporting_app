import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/navigation_provider.dart';
import '../../providers/staff_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/staff_nav_bar.dart';
import 'staff_profile_screen.dart';
import 'staff_reports_screen.dart';

/// Root shell for staff: an IndexedStack of tabs plus the staff nav bar.
/// Owns the all-incidents stream lifecycle.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  @override
  void initState() {
    super.initState();
    context.read<StaffProvider>().startListening();
  }

  @override
  void dispose() {
    context.read<StaffProvider>().stopListening();
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
            StaffReportsScreen(),
            StaffProfileScreen(),
          ],
        ),
        bottomNavigationBar: StaffNavBar(
          currentIndex: nav.currentIndex,
          onSelect: nav.setIndex,
        ),
      ),
    );
  }
}
