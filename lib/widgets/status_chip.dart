import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';

/// A pill-shaped status badge. Maps [IncidentStatus] to label + colors.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (Color, Color) _colors(IncidentStatus status) => switch (status) {
        IncidentStatus.submitted => (
            AppColors.statusSubmittedBg,
            AppColors.statusSubmittedText,
          ),
        IncidentStatus.inProgress => (
            AppColors.statusProgressBg,
            AppColors.statusProgressText,
          ),
        IncidentStatus.resolved => (
            AppColors.statusResolvedBg,
            AppColors.statusResolvedText,
          ),
      };
}
