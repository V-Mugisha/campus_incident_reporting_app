import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bold section label with an optional grey suffix (e.g. "(optional)").
class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel({super.key, required this.label, this.suffix});

  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (suffix != null)
            TextSpan(
              text: ' $suffix',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
