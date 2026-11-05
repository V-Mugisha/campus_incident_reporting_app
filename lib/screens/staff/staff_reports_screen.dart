import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/staff_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/report_search_bar.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/user_avatar.dart';
import '../shared/incident_details_screen.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return SafeArea(
      child: Column(
        children: [
          _Header(userName: user?.firstName ?? ''),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                provider.startListening();
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 4,
                  bottom: kNavBarClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StaffBanner(
                      onReview: () => provider
                          .setStatusFilter(IncidentStatus.submitted.name),
                    ),
                    const SizedBox(height: 16),
                    const _SummaryRow(),
                    const SizedBox(height: 16),
                    ReportSearchBar(onChanged: provider.setSearch),
                    const SizedBox(height: 16),
                    _ResultHeader(
                      count: provider.filteredIncidents.length,
                      hasFilters: provider.hasActiveFilters,
                      onClear: provider.clearFilters,
                    ),
                    const SizedBox(height: 12),
                    _buildContent(context, provider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, StaffProvider p) {
    if (p.isLoading && p.all.isEmpty) {
      return const Column(
        children: [
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
        ],
      );
    }

    if (p.errorMessage != null && p.all.isEmpty) {
      return ErrorState(
        title: "Couldn't load incidents",
        onRetry: p.startListening,
      );
    }

    if (p.all.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No reports yet',
        subtitle: 'Student reports will show up here.',
      );
    }

    if (p.filteredIncidents.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching reports',
        subtitle: 'Try a different search or clear your filters.',
        secondaryLabel: 'Clear filters',
        onSecondary: p.clearFilters,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < p.filteredIncidents.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          IncidentCard(
            incident: p.filteredIncidents[i],
            showReporter: true,
            onTap: () => _openDetails(context, p.filteredIncidents[i].id),
          ),
        ],
      ],
    );
  }

  void _openDetails(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentDetailsScreen(incidentId: id),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final greeting = userName.isEmpty ? 'Hello 👋' : 'Hello, $userName 👋';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
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
                  'Here are the latest campus reports.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          UserAvatar(
            name: userName,
            onTap: () => context.read<NavigationProvider>().setIndex(1),
          ),
        ],
      ),
    );
  }
}

class _StaffBanner extends StatelessWidget {
  const _StaffBanner({required this.onReview});

  final VoidCallback onReview;

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
              Icons.fact_check_outlined,
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
                    'Help resolve campus issues',
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
                    'Review student reports and update their status.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onReview,
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
                            Icons.fact_check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Review new reports',
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
    final p = context.watch<StaffProvider>();

    return Row(
      children: [
        Expanded(
          child: _tap(
            () => p.setStatusFilter(null),
            child: SummaryCard(
              label: 'All',
              count: p.totalCount,
              backgroundColor: AppColors.primaryLight,
              icon: Icons.description_outlined,
              iconColor: AppColors.primary,
              selected: p.statusFilter == null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _tap(
            () => p.setStatusFilter(IncidentStatus.submitted.name),
            child: SummaryCard(
              label: 'Submitted',
              count: p.submittedCount,
              backgroundColor: AppColors.tilePinkBg,
              icon: Icons.error_rounded,
              iconColor: AppColors.tilePink,
              selected: p.statusFilter == IncidentStatus.submitted.name,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _tap(
            () => p.setStatusFilter(IncidentStatus.inProgress.name),
            child: SummaryCard(
              label: 'In Progress',
              count: p.inProgressCount,
              backgroundColor: AppColors.tileBlueBg,
              icon: Icons.schedule_rounded,
              iconColor: AppColors.tileBlue,
              selected: p.statusFilter == IncidentStatus.inProgress.name,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _tap(
            () => p.setStatusFilter(IncidentStatus.resolved.name),
            child: SummaryCard(
              label: 'Resolved',
              count: p.resolvedCount,
              backgroundColor: AppColors.statusResolvedBg,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.statusResolvedText,
              selected: p.statusFilter == IncidentStatus.resolved.name,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tap(VoidCallback onTap, {required Widget child}) {
    return GestureDetector(onTap: onTap, child: child);
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.count,
    required this.hasFilters,
    required this.onClear,
  });

  final int count;
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$count reports',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        if (hasFilters)
          InkWell(
            onTap: onClear,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Clear filters',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
