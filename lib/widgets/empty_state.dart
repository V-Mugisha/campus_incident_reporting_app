import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'primary_button.dart';

/// A centered empty-state placeholder with optional primary/secondary actions.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

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
          child: Icon(icon, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        if (primaryLabel != null && onPrimary != null) ...[
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: PrimaryButton(label: primaryLabel!, onPressed: onPrimary),
          ),
        ],
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSecondary,
            child: Text(
              secondaryLabel!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
