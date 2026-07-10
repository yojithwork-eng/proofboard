import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/mode_styles.dart';
import '../controllers/planned_session_controller.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/app_mode.dart';
import '../models/planned_session.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';
import '../utils/skill_points_utils.dart';
import '../widgets/day_timeline.dart';
import 'add_proof_screen.dart';
import 'edit_proof_screen.dart';
import 'plan_ahead_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  bool _currentModeOnly = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDay = ProofDateUtils.dateOnly(today);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlannedSessionController>().refreshMissedSessions();
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    });
  }

  void _openEditScreen(BuildContext context, Proof proof) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditProofScreen(proof: proof),
      ),
    );
  }

  void _openPlanAhead(BuildContext context, {PlannedSession? session}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PlanAheadScreen(
          initialDate: _selectedDay,
          session: session,
        ),
      ),
    );
  }

  void _openLogProofForPlan(BuildContext context, PlannedSession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddProofScreen(
          standalone: true,
          onSaved: () {},
          initialSkillId: session.skillId,
          initialTitle: session.title,
          initialNote: session.note,
          initialDate: session.date,
          initialStartTime: session.plannedStartTime,
          initialEndTime: session.plannedEndTime,
          initialPlannedSessionId: session.id,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Proof proof) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete proof?'),
          content: Text(
            'This will remove "${proof.title}" from your local calendar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      final proofController = context.read<ProofController>();
      final plannedController = context.read<PlannedSessionController>();
      await proofController.deleteProof(proof.id);
      await plannedController.unlinkProof(proof.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proof deleted')),
        );
      }
    }
  }

  Future<void> _confirmDeletePlan(
    BuildContext context,
    PlannedSession session,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete planned session?'),
          content: Text(
            'This will remove "${session.title}" from your schedule.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      final deleted =
          await context.read<PlannedSessionController>().deleteSession(
                session.id,
              );
      if (deleted?.completedProofId != null && context.mounted) {
        final proofController = context.read<ProofController>();
        for (final proof in proofController.proofs) {
          if (proof.id == deleted!.completedProofId) {
            await proofController.updateProof(
              proof.copyWith(plannedSessionId: null, bonusSp: 0),
            );
            break;
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planned session deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProofController, SkillController, SettingsController,
        PlannedSessionController>(
      builder: (
        context,
        proofController,
        skillController,
        settings,
        plannedController,
        child,
      ) {
        final appMode = settings.appMode;
        final filterAppMode = _currentModeOnly ? appMode : null;
        final selectedProofs = _proofsForDay(
          proofController.proofs,
          _selectedDay,
          skillController,
          mode: filterAppMode,
        );
        final selectedPlannedSessions = _plannedSessionsForDay(
          plannedController.sessions,
          _selectedDay,
          skillController,
          mode: filterAppMode,
        );
        final selectedDaySp =
            SkillPointsUtils.spForDay(selectedProofs, _selectedDay);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _CalendarHeader(mode: appMode),
            const SizedBox(height: 18),
            _MonthCard(
              visibleMonth: _visibleMonth,
              selectedDay: _selectedDay,
              proofs: proofController.proofs,
              plannedSessions: plannedController.sessions,
              skillController: skillController,
              mode: appMode,
              currentModeOnly: _currentModeOnly,
              onFilterChanged: (value) {
                setState(() => _currentModeOnly = value);
              },
              onPreviousMonth: () => _changeMonth(-1),
              onNextMonth: () => _changeMonth(1),
              onSelectDay: (day) {
                setState(() => _selectedDay = day);
              },
            ),
            const SizedBox(height: 22),
            _SelectedDayHeader(
              selectedDay: _selectedDay,
              proofCount: selectedProofs.length,
              planCount: selectedPlannedSessions.length,
              daySp: selectedDaySp,
              onPlanAhead: () => _openPlanAhead(context),
            ),
            const SizedBox(height: 12),
            DayTimeline(
              day: _selectedDay,
              proofs: selectedProofs,
              plannedSessions: selectedPlannedSessions,
              skills: skillController.skills,
              onLogPlannedSession: (session) =>
                  _openLogProofForPlan(context, session),
              onEditPlannedSession: (session) =>
                  _openPlanAhead(context, session: session),
              onDeletePlannedSession: (session) =>
                  _confirmDeletePlan(context, session),
              onEditProof: (proof) => _openEditScreen(context, proof),
              onDeleteProof: (proof) => _confirmDelete(context, proof),
            ),
          ],
        );
      },
    );
  }

  List<Proof> _proofsForDay(
    List<Proof> proofs,
    DateTime day,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return proofs.where((proof) {
      final sameDay = ProofDateUtils.isSameDay(proof.date, day);
      if (!sameDay) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return skillFitsAppMode(skillController.skillById(proof.skillId), mode);
    }).toList();
  }

  List<PlannedSession> _plannedSessionsForDay(
    List<PlannedSession> sessions,
    DateTime day,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return sessions.where((session) {
      final sameDay = ProofDateUtils.isSameDay(session.date, day);
      if (!sameDay) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return session.mode == mode ||
          skillFitsAppMode(skillController.skillById(session.skillId), mode);
    }).toList();
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: modeGradientColors(mode),
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.calendar_month, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistency calendar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'See which days you showed up and what skills you built.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.visibleMonth,
    required this.selectedDay,
    required this.proofs,
    required this.plannedSessions,
    required this.skillController,
    required this.mode,
    required this.currentModeOnly,
    required this.onFilterChanged,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final List<Proof> proofs;
  final List<PlannedSession> plannedSessions;
  final SkillController skillController;
  final AppMode mode;
  final bool currentModeOnly;
  final ValueChanged<bool> onFilterChanged;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _calendarDaysFor(visibleMonth);
    final filterAppMode = currentModeOnly ? mode : null;
    final monthProofs = _proofsForVisibleMonth(
      proofs,
      visibleMonth,
      skillController,
      mode: filterAppMode,
    );
    final monthPlans = _plannedSessionsForVisibleMonth(
      plannedSessions,
      visibleMonth,
      skillController,
      mode: filterAppMode,
    );
    final activeDays = monthProofs
        .map((proof) => ProofDateUtils.dateOnly(proof.date))
        .followedBy(monthPlans.map((session) => session.date))
        .map((day) => day.millisecondsSinceEpoch)
        .toSet()
        .length;
    final topSkill = _topSkillForMonth(monthProofs, skillController);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _monthLabel(visibleMonth),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MonthSummary(
            activeDays: activeDays,
            totalProofs: monthProofs.length,
            topSkill: topSkill,
          ),
          const SizedBox(height: 12),
          _CalendarFilter(
            mode: mode,
            currentModeOnly: currentModeOnly,
            onChanged: onFilterChanged,
          ),
          const SizedBox(height: 12),
          _CalendarHint(mode: mode, currentModeOnly: currentModeOnly),
          const SizedBox(height: 10),
          const _WeekdayRow(),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: days.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.74,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final dayProofs = _proofsForCalendarDay(
                proofs,
                day,
                skillController,
                mode: filterAppMode,
              );
              final dayPlans = _plannedSessionsForCalendarDay(
                plannedSessions,
                day,
                skillController,
                mode: filterAppMode,
              );
              final skillsForDay = _skillsForProofs(
                dayProofs,
                skillController,
                focusMode: mode,
              );
              final plannedSkillsForDay = _skillsForPlans(
                dayPlans,
                skillController,
                focusMode: mode,
              );

              return _CalendarDayTile(
                day: day,
                isVisibleMonth: day.month == visibleMonth.month,
                isSelected: ProofDateUtils.isSameDay(day, selectedDay),
                isToday: ProofDateUtils.isSameDay(day, DateTime.now()),
                skills: skillsForDay,
                plannedSkills: plannedSkillsForDay,
                hasMissedPlan: dayPlans.any(
                  (session) => session.status == PlannedSessionStatus.missed,
                ),
                hasCompletedPlan: dayPlans.any(
                  (session) => session.status == PlannedSessionStatus.completed,
                ),
                focusMode: mode,
                onTap: () => onSelectDay(day),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DateTime> _calendarDaysFor(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final leadingDays = firstDay.weekday % 7;
    final firstVisibleDay = firstDay.subtract(Duration(days: leadingDays));

    return List.generate(
      42,
      (index) => firstVisibleDay.add(Duration(days: index)),
    );
  }

  List<Proof> _proofsForCalendarDay(
    List<Proof> proofs,
    DateTime day,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return proofs.where((proof) {
      final sameDay = ProofDateUtils.isSameDay(proof.date, day);
      if (!sameDay) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return skillFitsAppMode(skillController.skillById(proof.skillId), mode);
    }).toList();
  }

  List<PlannedSession> _plannedSessionsForCalendarDay(
    List<PlannedSession> sessions,
    DateTime day,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return sessions.where((session) {
      final sameDay = ProofDateUtils.isSameDay(session.date, day);
      if (!sameDay) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return session.mode == mode ||
          skillFitsAppMode(skillController.skillById(session.skillId), mode);
    }).toList();
  }

  List<Proof> _proofsForVisibleMonth(
    List<Proof> proofs,
    DateTime month,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return proofs.where((proof) {
      final sameMonth =
          proof.date.year == month.year && proof.date.month == month.month;
      if (!sameMonth) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return skillFitsAppMode(skillController.skillById(proof.skillId), mode);
    }).toList();
  }

  List<PlannedSession> _plannedSessionsForVisibleMonth(
    List<PlannedSession> sessions,
    DateTime month,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return sessions.where((session) {
      final sameMonth =
          session.date.year == month.year && session.date.month == month.month;
      if (!sameMonth) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return session.mode == mode ||
          skillFitsAppMode(skillController.skillById(session.skillId), mode);
    }).toList();
  }

  List<Skill> _skillsForProofs(
    List<Proof> proofs,
    SkillController skillController, {
    AppMode? focusMode,
  }) {
    final skillIds = <String>{};
    final skills = <Skill>[];

    for (final proof in proofs) {
      final skill = skillController.skillById(proof.skillId);
      if (skillIds.add(skill.id)) {
        skills.add(skill);
      }
    }

    if (focusMode != null) {
      skills.sort((a, b) {
        final aFocused = skillFitsAppMode(a, focusMode);
        final bFocused = skillFitsAppMode(b, focusMode);
        if (aFocused == bFocused) {
          return a.name.compareTo(b.name);
        }
        return aFocused ? -1 : 1;
      });
    }

    return skills;
  }

  List<Skill> _skillsForPlans(
    List<PlannedSession> sessions,
    SkillController skillController, {
    AppMode? focusMode,
  }) {
    final skillIds = <String>{};
    final skills = <Skill>[];

    for (final session in sessions) {
      final skill = skillController.skillById(session.skillId);
      if (skillIds.add(skill.id)) {
        skills.add(skill);
      }
    }

    if (focusMode != null) {
      skills.sort((a, b) {
        final aFocused = skillFitsAppMode(a, focusMode);
        final bFocused = skillFitsAppMode(b, focusMode);
        if (aFocused == bFocused) {
          return a.name.compareTo(b.name);
        }
        return aFocused ? -1 : 1;
      });
    }

    return skills;
  }

  Skill? _topSkillForMonth(
    List<Proof> monthProofs,
    SkillController skillController,
  ) {
    if (monthProofs.isEmpty) {
      return null;
    }

    final counts = <String, int>{};
    for (final proof in monthProofs) {
      counts.update(proof.skillId, (count) => count + 1, ifAbsent: () => 1);
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return skillController.skillById(sorted.first.key);
  }

  String _monthLabel(DateTime month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[month.month - 1]} ${month.year}';
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.activeDays,
    required this.totalProofs,
    required this.topSkill,
  });

  final int activeDays;
  final int totalProofs;
  final Skill? topSkill;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryPill(
            label: 'Active days',
            value: '$activeDays',
            icon: Icons.event_available_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryPill(
            label: 'Proofs',
            value: '$totalProofs',
            icon: Icons.task_alt,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryPill(
            label: 'Top skill',
            value: topSkill?.name ?? 'None',
            icon: Icons.emoji_events_outlined,
            color: topSkill == null ? null : skillColor(topSkill!),
          ),
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _CalendarFilter extends StatelessWidget {
  const _CalendarFilter({
    required this.mode,
    required this.currentModeOnly,
    required this.onChanged,
  });

  final AppMode mode;
  final bool currentModeOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: [
        const ButtonSegment(
          value: false,
          icon: Icon(Icons.all_inclusive),
          label: Text('All proofs'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(mode.icon),
          label: Text('${mode.shortLabel} only'),
        ),
      ],
      selected: {currentModeOnly},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _CalendarHint extends StatelessWidget {
  const _CalendarHint({
    required this.mode,
    required this.currentModeOnly,
  });

  final AppMode mode;
  final bool currentModeOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = modeAccentColor(mode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: accent, size: 9),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentModeOnly
                  ? 'Showing ${mode.displayName.toLowerCase()} schedule items only.'
                  : 'Filled dots are completed proofs. Hollow dots are planned sessions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({
    required this.day,
    required this.isVisibleMonth,
    required this.isSelected,
    required this.isToday,
    required this.skills,
    required this.plannedSkills,
    required this.hasMissedPlan,
    required this.hasCompletedPlan,
    required this.focusMode,
    required this.onTap,
  });

  final DateTime day;
  final bool isVisibleMonth;
  final bool isSelected;
  final bool isToday;
  final List<Skill> skills;
  final List<Skill> plannedSkills;
  final bool hasMissedPlan;
  final bool hasCompletedPlan;
  final AppMode focusMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasProofs = skills.isNotEmpty;
    final hasPlans = plannedSkills.isNotEmpty;
    final hasFocusedProof =
        skills.any((skill) => skillFitsAppMode(skill, focusMode));
    final primarySkillColor = hasProofs
        ? skillColor(skills.first)
        : hasPlans
            ? skillColor(plannedSkills.first)
            : null;
    final proofAlpha = hasFocusedProof ? 0.16 : 0.09;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.16)
              : hasProofs || hasPlans
                  ? primarySkillColor!.withValues(
                      alpha: hasProofs ? proofAlpha : 0.06,
                    )
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : hasMissedPlan
                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.28)
                    : hasCompletedPlan
                        ? const Color(0xFF00A884).withValues(alpha: 0.45)
                        : isToday
                            ? colorScheme.primary.withValues(alpha: 0.45)
                            : hasFocusedProof
                                ? colorScheme.primary.withValues(alpha: 0.26)
                                : colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isVisibleMonth
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.34),
                    fontWeight: isSelected || hasProofs
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 3),
            _SkillMarkers(
              skills: skills,
              plannedSkills: plannedSkills,
              focusMode: focusMode,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillMarkers extends StatelessWidget {
  const _SkillMarkers({
    required this.skills,
    required this.plannedSkills,
    required this.focusMode,
  });

  final List<Skill> skills;
  final List<Skill> plannedSkills;
  final AppMode focusMode;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty && plannedSkills.isEmpty) {
      return const SizedBox(height: 12);
    }

    final visibleSkills = skills.take(3).toList();
    final visiblePlans = plannedSkills.take(3 - visibleSkills.length).toList();
    final extraCount = (skills.length + plannedSkills.length) -
        (visibleSkills.length + visiblePlans.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...visibleSkills.map(
          (skill) {
            final isFocused = skillFitsAppMode(skill, focusMode);
            return Container(
              width: isFocused ? 6 : 5,
              height: isFocused ? 6 : 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: skillColor(skill),
                shape: BoxShape.circle,
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: skillColor(skill).withValues(alpha: 0.35),
                          blurRadius: 5,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        ...visiblePlans.map(
          (skill) => Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: skillColor(skill), width: 1.2),
            ),
          ),
        ),
        if (extraCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              '+$extraCount',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
            ),
          ),
      ],
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({
    required this.selectedDay,
    required this.proofCount,
    required this.planCount,
    required this.daySp,
    required this.onPlanAhead,
  });

  final DateTime selectedDay;
  final int proofCount;
  final int planCount;
  final int daySp;
  final VoidCallback onPlanAhead;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ProofDateUtils.friendlyDate(selectedDay),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DayMetricPill(
                      icon: Icons.event_available_outlined,
                      label: '$planCount planned',
                    ),
                    _DayMetricPill(
                      icon: Icons.task_alt,
                      label: '$proofCount done',
                    ),
                    _DayMetricPill(
                      icon: Icons.bolt,
                      label: '$daySp SP',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onPlanAhead,
            icon: const Icon(Icons.add),
            label: const Text('Plan'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(92, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayMetricPill extends StatelessWidget {
  const _DayMetricPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
