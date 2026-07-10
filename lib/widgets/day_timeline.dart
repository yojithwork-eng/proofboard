import 'package:flutter/material.dart';

import '../constants/categories.dart';
import '../models/planned_session.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';
import 'empty_state.dart';
import 'schedule_block_card.dart';

class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.day,
    required this.proofs,
    required this.plannedSessions,
    required this.skills,
    required this.onLogPlannedSession,
    required this.onEditPlannedSession,
    required this.onDeletePlannedSession,
    required this.onEditProof,
    required this.onDeleteProof,
    this.maxItems,
  });

  final DateTime day;
  final List<Proof> proofs;
  final List<PlannedSession> plannedSessions;
  final List<Skill> skills;
  final ValueChanged<PlannedSession> onLogPlannedSession;
  final ValueChanged<PlannedSession> onEditPlannedSession;
  final ValueChanged<PlannedSession> onDeletePlannedSession;
  final ValueChanged<Proof> onEditProof;
  final ValueChanged<Proof> onDeleteProof;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final entries = <_TimelineEntry>[
      ...plannedSessions.map(_TimelineEntry.planned),
      ...proofs.map(_TimelineEntry.proof),
    ]..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    final visibleEntries = maxItems == null
        ? entries
        : entries.take(maxItems!).toList(growable: false);

    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_outlined,
        title: 'No schedule yet',
        message:
            'Plan a skill block or log a proof to start building this day.',
      );
    }

    return Column(
      children: visibleEntries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: entry.plannedSession != null
                  ? _PlannedSessionCard(
                      session: entry.plannedSession!,
                      skill: _skillById(entry.plannedSession!.skillId),
                      onLog: () => onLogPlannedSession(entry.plannedSession!),
                      onEdit: () => onEditPlannedSession(entry.plannedSession!),
                      onDelete: () =>
                          onDeletePlannedSession(entry.plannedSession!),
                    )
                  : _ProofSessionCard(
                      proof: entry.proof!,
                      skill: _skillById(entry.proof!.skillId),
                      onEdit: () => onEditProof(entry.proof!),
                      onDelete: () => onDeleteProof(entry.proof!),
                    ),
            ),
          )
          .toList(),
    );
  }

  Skill _skillById(String skillId) {
    return skills.firstWhere(
      (skill) => skill.id == skillId,
      orElse: () => starterSkills.firstWhere(
        (skill) => skill.id == skillId,
        orElse: () => const Skill(
          id: 'skill_other',
          name: 'Other',
          colorValue: defaultSkillColorValue,
          iconName: 'auto_awesome',
          mode: SkillMode.general,
        ),
      ),
    );
  }
}

class _PlannedSessionCard extends StatelessWidget {
  const _PlannedSessionCard({
    required this.session,
    required this.skill,
    required this.onLog,
    required this.onEdit,
    required this.onDelete,
  });

  final PlannedSession session;
  final Skill skill;
  final VoidCallback onLog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, session.status);
    final canLog = session.completedProofId == null;

    return ScheduleBlockCard(
      skill: skill,
      title: session.title,
      subtitle: session.note,
      timeLabel:
          '${ProofDateUtils.formatTimeRange(session.plannedStartTime, session.plannedEndTime)} • ${session.plannedMinutes} planned min',
      statusLabel: session.status.displayName,
      statusColor: statusColor,
      icon: skillIcon(skill),
      muted: session.status == PlannedSessionStatus.missed,
      onPrimary: canLog ? onLog : null,
      primaryLabel: 'Log Proof',
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Color _statusColor(BuildContext context, PlannedSessionStatus status) {
    return switch (status) {
      PlannedSessionStatus.planned => Theme.of(context).colorScheme.primary,
      PlannedSessionStatus.completed => const Color(0xFF00A884),
      PlannedSessionStatus.partiallyCompleted => const Color(0xFFF59E0B),
      PlannedSessionStatus.missed =>
        Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }
}

class _ProofSessionCard extends StatelessWidget {
  const _ProofSessionCard({
    required this.proof,
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  });

  final Proof proof;
  final Skill skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeRange = ProofDateUtils.formatTimeRange(
      proof.startTime,
      proof.endTime,
    );

    return ScheduleBlockCard(
      skill: skill,
      title: proof.title,
      subtitle: proof.note,
      timeLabel: timeRange.isEmpty
          ? '${proof.minutes} min focused'
          : '$timeRange • ${proof.minutes} min focused',
      statusLabel: proof.plannedSessionId == null ? 'Completed' : 'Plan done',
      statusColor: const Color(0xFF00A884),
      icon: Icons.check_circle_outline,
      spLabel: '+${proof.totalSp} SP',
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    this.plannedSession,
    this.proof,
    required this.sortMinutes,
  });

  factory _TimelineEntry.planned(PlannedSession session) {
    return _TimelineEntry(
      plannedSession: session,
      sortMinutes:
          ProofDateUtils.minutesFromTimeString(session.plannedStartTime) ?? 0,
    );
  }

  factory _TimelineEntry.proof(Proof proof) {
    return _TimelineEntry(
      proof: proof,
      sortMinutes:
          ProofDateUtils.minutesFromTimeString(proof.startTime) ?? 1440,
    );
  }

  final PlannedSession? plannedSession;
  final Proof? proof;
  final int sortMinutes;
}
