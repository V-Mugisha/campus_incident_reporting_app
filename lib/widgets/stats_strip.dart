import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A three-column stats card with animated count-up numbers.
class StatsStrip extends StatelessWidget {
  const StatsStrip({
    super.key,
    required this.total,
    required this.inProgress,
    required this.resolved,
  });

  final int total;
  final int inProgress;
  final int resolved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _Stat(number: total, label: 'Total Reports', color: AppColors.primary),
          const _Divider(),
          _Stat(
            number: inProgress,
            label: 'In Progress',
            color: AppColors.tileBlue,
          ),
          const _Divider(),
          _Stat(
            number: resolved,
            label: 'Resolved',
            color: AppColors.statusResolvedText,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.number,
    required this.label,
    required this.color,
  });

  final int number;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: number),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, _) => Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}
