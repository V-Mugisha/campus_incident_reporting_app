import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import 'status_chip.dart';

/// A compact incident summary row used in lists.
class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
          _Thumbnail(incident: incident),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incident.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      relativeTime(incident.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(status: incident.status),
              const SizedBox(height: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final url = incident.photoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _categoryTile(),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _categoryTile(),
        ),
      );
    }
    return _categoryTile();
  }

  Widget _categoryTile() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        categoryIcon(incident.category),
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}

/// Icon for an incident category (shared by card thumbnails and forms).
IconData categoryIcon(IncidentCategory category) => switch (category) {
      IncidentCategory.brokenFacility => Icons.build_rounded,
      IncidentCategory.waterShortage => Icons.water_drop_rounded,
      IncidentCategory.electricityOutage => Icons.bolt_rounded,
      IncidentCategory.damagedFurniture => Icons.chair_rounded,
      IncidentCategory.sanitation => Icons.delete_outline_rounded,
      IncidentCategory.safetyConcern => Icons.warning_rounded,
      IncidentCategory.other => Icons.report_gmailerrorred_rounded,
    };
