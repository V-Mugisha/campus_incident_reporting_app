import 'package:flutter/material.dart';

import '../../models/incident.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format.dart';

enum _NodeState { completed, current, upcoming }

/// A horizontal status stepper (Submitted -> In Progress -> Resolved).
///
/// Shared so the staff screens can reuse it unchanged.
class StatusTimeline extends StatefulWidget {
  const StatusTimeline({
    super.key,
    required this.entries,
    required this.current,
  });

  final List<StatusEntry> entries;
  final IncidentStatus current;

  @override
  State<StatusTimeline> createState() => _StatusTimelineState();
}

class _StatusTimelineState extends State<StatusTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _fill.dispose();
    _pulse.dispose();
    super.dispose();
  }

  int _order(IncidentStatus s) => IncidentStatus.values.indexOf(s);

  _NodeState _stateFor(IncidentStatus stage) {
    if (widget.current == IncidentStatus.resolved) return _NodeState.completed;
    final o = _order(stage);
    final co = _order(widget.current);
    if (o < co) return _NodeState.completed;
    if (o == co) return _NodeState.current;
    return _NodeState.upcoming;
  }

  DateTime? _timestampFor(IncidentStatus stage) {
    DateTime? latest;
    for (final e in widget.entries) {
      if (e.status == stage && (latest == null || e.timestamp.isAfter(latest))) {
        latest = e.timestamp;
      }
    }
    return latest;
  }

  bool _segmentFilled(int leftIndex) =>
      _stateFor(IncidentStatus.values[leftIndex]) == _NodeState.completed;

  String _message() {
    switch (widget.current) {
      case IncidentStatus.submitted:
        return 'Your report has been received and is waiting for staff review.';
      case IncidentStatus.inProgress:
        return 'Campus staff are working on this issue.';
      case IncidentStatus.resolved:
        return 'This issue has been marked as resolved.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = IncidentStatus.values;
    return Container(
      padding: const EdgeInsets.all(20),
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
              _node(stages[0]),
              Expanded(child: _line(0)),
              _node(stages[1]),
              Expanded(child: _line(1)),
              _node(stages[2]),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _message(),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(IncidentStatus stage) {
    final state = _stateFor(stage);
    final ts = _timestampFor(stage);
    final timeLabel = state == _NodeState.upcoming
        ? 'Pending'
        : (ts == null ? '' : shortDate(ts));
    final timeColor = state == _NodeState.upcoming
        ? AppColors.textHint
        : AppColors.textSecondary;

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          SizedBox(height: 32, child: Center(child: _circle(stage, state))),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stage.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeLabel,
              style: TextStyle(color: timeColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(IncidentStatus stage, _NodeState state) {
    switch (state) {
      case _NodeState.completed:
        final color = stage == IncidentStatus.resolved
            ? AppColors.statusResolvedText
            : AppColors.primary;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
        );
      case _NodeState.current:
        return Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = _pulse.value;
                return Container(
                  width: 32 + 20 * t,
                  height: 32 + 20 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.2 * (1 - t)),
                  ),
                );
              },
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      case _NodeState.upcoming:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.timelineIdleBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.timelineIdle, width: 2),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.timelineIdle,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
    }
  }

  Widget _line(int leftIndex) {
    final filled = _segmentFilled(leftIndex);
    return Padding(
      padding: const EdgeInsets.only(top: 14.5),
      child: SizedBox(
        height: 3,
        child: filled
            ? AnimatedBuilder(
                animation: _fill,
                builder: (context, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _fill.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: AppColors.timelineIdle,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
      ),
    );
  }
}
