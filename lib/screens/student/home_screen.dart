import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/placeholder_incidents.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/user_avatar.dart';
import 'report_placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final nav = context.read<NavigationProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // TODO: refresh real data when wired to IncidentProvider.
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: kNavBarClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(userName: user?.firstName ?? ''),
              const SizedBox(height: 24),
              _HeroBanner(
                onReport: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportPlaceholderScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Report Summary',
                onSeeAll: () => nav.setIndex(1),
              ),
              const SizedBox(height: 12),
              const _SummaryRow(),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Recent Reports',
                onSeeAll: () => nav.setIndex(1),
              ),
              const SizedBox(height: 12),
              const _RecentReports(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final greeting =
        userName.isEmpty ? 'Hello 👋' : 'Hello, $userName 👋';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Help make our campus safer.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Text(
                'Report issues and track their resolution.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _NotificationButton(),
        const SizedBox(width: 12),
        UserAvatar(
          name: userName,
          onTap: () => context.read<NavigationProvider>().setIndex(2),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No new notifications')),
        );
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 48,
            child: Icon(
              Icons.apartment_rounded,
              color: Colors.white.withValues(alpha: 0.25),
              size: 64,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.62,
                  child: Text(
                    'See an issue on campus?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.62,
                  child: Text(
                    'Report it and help improve our learning environment.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onReport,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Report an Issue',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    final s = placeholderSummary;
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            label: 'My Reports',
            count: s.myReports,
            backgroundColor: AppColors.primaryLight,
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryCard(
            label: 'In Progress',
            count: s.inProgress,
            backgroundColor: AppColors.tileBlueBg,
            icon: Icons.schedule_rounded,
            iconColor: AppColors.tileBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryCard(
            label: 'Resolved',
            count: s.resolved,
            backgroundColor: AppColors.statusResolvedBg,
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.statusResolvedText,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SummaryCard(
            label: 'Submitted',
            count: s.submitted,
            backgroundColor: AppColors.tilePinkBg,
            icon: Icons.error_rounded,
            iconColor: AppColors.tilePink,
          ),
        ),
      ],
    );
  }
}

class _RecentReports extends StatelessWidget {
  const _RecentReports();

  @override
  Widget build(BuildContext context) {
    final incidents = placeholderIncidents.take(3).toList();
    if (incidents.isEmpty) return const _EmptyState();

    return Column(
      children: [
        for (var i = 0; i < incidents.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          IncidentCard(incident: incidents[i]),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.inbox_outlined,
            color: AppColors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No reports yet',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap Report to submit your first issue.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
