import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/staff_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/report_search_bar.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/stats_strip.dart';
import '../../widgets/status_filter_bar.dart';
import '../shared/incident_details_screen.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    return SafeArea(
      child: Column(
        children: [
          const _TopBar(),
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
                    StatsStrip(
                      total: provider.totalCount,
                      inProgress: provider.inProgressCount,
                      resolved: provider.resolvedCount,
                    ),
                    const SizedBox(height: 16),
                    ReportSearchBar(onChanged: provider.setSearch),
                    const SizedBox(height: 14),
                    StatusFilterBar(
                      selected: provider.statusFilter,
                      onSelected: provider.setStatusFilter,
                      totalCount: provider.totalCount,
                      submittedCount: provider.submittedCount,
                      inProgressCount: provider.inProgressCount,
                      resolvedCount: provider.resolvedCount,
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Review Reports',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
