import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Placeholder for the Reports tab (report list comes in a later phase).
class ReportsPlaceholderScreen extends StatelessWidget {
  const ReportsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          SizedBox(height: 12),
          Text(
            'Reports coming soon',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
