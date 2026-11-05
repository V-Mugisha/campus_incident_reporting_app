import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Placeholder for the report form (report submission comes in a later phase).
class ReportPlaceholderScreen extends StatelessWidget {
  const ReportPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Report an Incident',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: const Center(
        child: Text(
          'Coming soon',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ),
    );
  }
}
