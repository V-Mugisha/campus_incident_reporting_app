import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';

/// Horizontally scrollable status filter chips with counts.
class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.totalCount,
    required this.submittedCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  final String? selected; // null means "All"
  final ValueChanged<String?> onSelected;
  final int totalCount;
  final int submittedCount;
  final int inProgressCount;
  final int resolvedCount;

  @override
  Widget build(BuildContext context) {
    final items = <(String?, String, int)>[
      (null, 'All', totalCount),
      (IncidentStatus.submitted.name, 'Submitted', submittedCount),
      (IncidentStatus.inProgress.name, 'In Progress', inProgressCount),
      (IncidentStatus.resolved.name, 'Resolved', resolvedCount),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Chip(
              label: items[i].$2,
              count: items[i].$3,
              selected: selected == items[i].$1,
              onTap: () => onSelected(items[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: ' $count',
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
