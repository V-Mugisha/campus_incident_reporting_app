import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident_category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/report_search_bar.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/stats_strip.dart';
import '../../widgets/status_filter_bar.dart';
import 'incident_details_screen.dart';
import 'report_incident_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final uid = context.read<AuthProvider>().currentUser?.id ?? '';

    return SafeArea(
      child: Column(
        children: [
          _TopBar(
            hasCategoryFilter: provider.categoryFilter != null,
            onFilter: () => _openCategorySheet(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                provider.startListening(uid);
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
                    if (provider.categoryFilter != null) ...[
                      const SizedBox(height: 12),
                      _CategoryChip(
                        category:
                            IncidentCategory.fromKey(provider.categoryFilter),
                        onClear: () => provider.setCategoryFilter(null),
                      ),
                    ],
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

  Widget _buildContent(BuildContext context, IncidentProvider p) {
    if (p.isLoading && p.allMine.isEmpty) {
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

    if (p.errorMessage != null) {
      return ErrorState(
        title: "Couldn't load your reports",
        onRetry: () => p.startListening(
          context.read<AuthProvider>().currentUser?.id ?? '',
        ),
      );
    }

    if (p.allMine.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No reports yet',
        subtitle: 'Tap Report to submit your first issue.',
        primaryLabel: 'Report an Issue',
        onPrimary: () => _openReport(context),
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
            onTap: () => _openDetails(context, p.filteredIncidents[i].id),
          ),
        ],
      ],
    );
  }

  Future<void> _openReport(BuildContext context) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
    }
  }

  void _openDetails(BuildContext context, String id) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => IncidentDetailsScreen(incidentId: id),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCategorySheet(BuildContext context) async {
    final provider = context.read<IncidentProvider>();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CategoryFilterSheet(initial: provider.categoryFilter),
    );
    if (result == null) return;
    provider.setCategoryFilter(result.isEmpty ? null : result);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.hasCategoryFilter, required this.onFilter});

  final bool hasCategoryFilter;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Reports',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onFilter,
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
                      Icons.tune_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  if (hasCategoryFilter)
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onClear});

  final IncidentCategory category;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
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

class _CategoryFilterSheet extends StatefulWidget {
  const _CategoryFilterSheet({required this.initial});

  final String? initial;

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter by category',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final tileWidth =
                    (constraints.maxWidth - 2 * spacing) / 3;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final category in IncidentCategory.values)
                      SizedBox(
                        width: tileWidth,
                        child: CategoryTile(
                          category: category,
                          selected: _selected == category.key,
                          onTap: () => setState(() {
                            _selected = _selected == category.key
                                ? null
                                : category.key;
                          }),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(''),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'Apply',
                    onPressed: () =>
                        Navigator.of(context).pop(_selected ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
