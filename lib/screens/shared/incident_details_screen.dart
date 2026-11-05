import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/staff_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format.dart';
import '../../utils/snackbar.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_title.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/status_chip.dart';
import '../student/full_screen_image_screen.dart';
import 'status_timeline.dart';

class IncidentDetailsScreen extends StatefulWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  Stream<Incident?>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= context.read<IncidentProvider>().watchIncident(widget.incidentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(incidentId: widget.incidentId),
            Expanded(
              child: StreamBuilder<Incident?>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const _LoadingBody();
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return _UnavailableBody(
                      onBack: () => Navigator.of(context).pop(),
                    );
                  }
                  return _DetailsBody(incident: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.incidentId});

  final String incidentId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Incident Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'copy') {
                Clipboard.setData(ClipboardData(text: incidentId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report ID copied')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'copy', child: Text('Copy report ID')),
            ],
            child: _CircleButton(
              icon: Icons.more_vert_rounded,
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Icon(icon, color: AppColors.textPrimary),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonCard(),
        SizedBox(height: 12),
        SkeletonCard(),
        SizedBox(height: 12),
        SkeletonCard(),
      ],
    );
  }
}

class _UnavailableBody extends StatelessWidget {
  const _UnavailableBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          const Text(
            'This report is no longer available',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onBack,
            child: const Text(
              'Go back',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryCard(incident: incident),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Status Timeline'),
              const SizedBox(height: 8),
              StatusTimeline(
                entries: incident.statusHistory,
                current: incident.status,
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Description'),
              const SizedBox(height: 8),
              _DescriptionCard(description: incident.description),
              if (incident.imageUrl != null && incident.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionTitle(title: 'Attached Photo'),
                const SizedBox(height: 8),
                _PhotoCard(imageUrl: incident.imageUrl!),
              ],
              const SizedBox(height: 24),
              _StatusControlSlot(incident: incident),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumbnail(incident),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (incident.location != null &&
                        incident.location!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              incident.location!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    StatusChip(status: incident.status, fontSize: 13),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.border),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Submitted on',
            child: Text(
              fullDateTime(incident.createdAt),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Reported by',
            child: Text(
              incident.reportedByName ?? 'Unknown',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.category_outlined,
            label: 'Category',
            child: Text(
              incident.category.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.tag_rounded,
            label: 'Report ID',
            child: Text(
              incident.id.length > 8 ? incident.id.substring(0, 8) : incident.id,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail(Incident incident) {
    if (incident.imageUrl != null && incident.imageUrl!.isNotEmpty) {
      return Hero(
        tag: 'incident-image-${incident.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            incident.imageUrl!,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _categoryTile(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _categoryTile(),
          ),
        ),
      );
    }
    return _categoryTile();
  }

  Widget _categoryTile() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.categoryAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        incident.category.icon,
        color: AppColors.categoryAccent,
        size: 40,
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SelectableText(
        description,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }
}

class _PhotoCard extends StatefulWidget {
  const _PhotoCard({required this.imageUrl});

  final String imageUrl;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  int _attempt = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FullScreenImageScreen(imageUrl: widget.imageUrl),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          widget.imageUrl,
          key: ValueKey(_attempt),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _shimmer(),
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Container(
      height: 220,
      color: AppColors.skeletonBase,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _fallback() {
    return Container(
      height: 220,
      color: AppColors.border,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            "Couldn't load image",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          TextButton(
            onPressed: () => setState(() => _attempt++),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Staff-only status update control. Hidden for students.
class _StatusControlSlot extends StatelessWidget {
  const _StatusControlSlot({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;
    if (!isStaff) return const SizedBox.shrink();
    return _StaffStatusControl(incident: incident);
  }
}

class _StaffStatusControl extends StatelessWidget {
  const _StaffStatusControl({required this.incident});

  final Incident incident;

  Future<void> _apply(
    BuildContext context,
    IncidentStatus status,
  ) async {
    final staff = context.read<StaffProvider>();
    final name = context.read<AuthProvider>().currentUser?.name ?? 'Staff';
    final ok = await staff.updateStatus(
      id: incident.id,
      status: status,
      changedBy: name,
    );
    if (!context.mounted) return;
    if (ok) {
      showSuccessSnackBar(context, 'Status updated to ${status.label}');
    } else {
      showErrorSnackBar(context, "Couldn't update the status. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = context.watch<StaffProvider>().isUpdating;
    final actions = _actionsFor(incident.status);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Update Status',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            if (actions[i].$3)
              PrimaryButton(
                label: actions[i].$2,
                isLoading: isUpdating,
                onPressed: () => _apply(context, actions[i].$1),
              )
            else
              OutlinedButton(
                onPressed: isUpdating ? null : () => _apply(context, actions[i].$1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(actions[i].$2),
              ),
          ],
        ],
      ),
    );
  }

  List<(IncidentStatus, String, bool)> _actionsFor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.submitted:
        return [
          (IncidentStatus.inProgress, 'Start Progress', true),
          (IncidentStatus.resolved, 'Mark Resolved', false),
        ];
      case IncidentStatus.inProgress:
        return [
          (IncidentStatus.resolved, 'Mark Resolved', true),
        ];
      case IncidentStatus.resolved:
        return [
          (IncidentStatus.inProgress, 'Reopen', false),
        ];
    }
  }
}
