import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/mode_styles.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/app_mode.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/proof_card.dart';
import 'edit_proof_screen.dart';

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
      await context.read<ProofController>().deleteProof(proof.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proof deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProofController, SkillController, SettingsController>(
      builder: (context, proofController, skillController, settings, child) {
        final appMode = settings.appMode;
        final filterAppMode = _currentModeOnly ? appMode : null;
        final selectedProofs = _proofsForDay(
          proofController.proofs,
          _selectedDay,
          skillController,
          mode: filterAppMode,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _CalendarHeader(mode: appMode),
            const SizedBox(height: 18),
            _MonthCard(
              visibleMonth: _visibleMonth,
              selectedDay: _selectedDay,
              proofs: proofController.proofs,
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
            ),
            const SizedBox(height: 12),
            if (selectedProofs.isEmpty)
              const EmptyState(
                icon: Icons.event_available_outlined,
                title: 'No proofs on this day',
                message:
                    'Pick another highlighted day or add a proof to start filling your consistency map.',
              )
            else
              ...selectedProofs.map(
                (proof) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ProofCard(
                    proof: proof,
                    skill: skillController.skillById(proof.skillId),
                    onTap: () => _openEditScreen(context, proof),
                    onEdit: () => _openEditScreen(context, proof),
                    onDelete: () => _confirmDelete(context, proof),
                  ),
                ),
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
      final sameDay = ProofDateUtils.isSameDay(proof.createdAt, day);
      if (!sameDay) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return skillFitsAppMode(skillController.skillById(proof.skillId), mode);
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
    final activeDays = monthProofs
        .map((proof) => ProofDateUtils.dateOnly(proof.createdAt))
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
              final skillsForDay = _skillsForProofs(
                dayProofs,
                skillController,
                focusMode: mode,
              );

              return _CalendarDayTile(
                day: day,
                isVisibleMonth: day.month == visibleMonth.month,
                isSelected: ProofDateUtils.isSameDay(day, selectedDay),
                isToday: ProofDateUtils.isSameDay(day, DateTime.now()),
                skills: skillsForDay,
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
      final sameDay = ProofDateUtils.isSameDay(proof.createdAt, day);
      if (!sameDay) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return skillFitsAppMode(skillController.skillById(proof.skillId), mode);
    }).toList();
  }

  List<Proof> _proofsForVisibleMonth(
    List<Proof> proofs,
    DateTime month,
    SkillController skillController, {
    AppMode? mode,
  }) {
    return proofs.where((proof) {
      final sameMonth = proof.createdAt.year == month.year &&
          proof.createdAt.month == month.month;
      if (!sameMonth) {
        return false;
      }

      if (mode == null) {
        return true;
      }

      return skillFitsAppMode(skillController.skillById(proof.skillId), mode);
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
                  ? 'Showing ${mode.displayName.toLowerCase()} proofs only. Dots use skill colors.'
                  : 'Dots show the skills you worked on that day. ${mode.displayName} skills appear first.',
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
    required this.focusMode,
    required this.onTap,
  });

  final DateTime day;
  final bool isVisibleMonth;
  final bool isSelected;
  final bool isToday;
  final List<Skill> skills;
  final AppMode focusMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasProofs = skills.isNotEmpty;
    final hasFocusedProof =
        skills.any((skill) => skillFitsAppMode(skill, focusMode));
    final primarySkillColor = hasProofs ? skillColor(skills.first) : null;
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
              : hasProofs
                  ? primarySkillColor!.withValues(alpha: proofAlpha)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
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
            _SkillMarkers(skills: skills, focusMode: focusMode),
          ],
        ),
      ),
    );
  }
}

class _SkillMarkers extends StatelessWidget {
  const _SkillMarkers({
    required this.skills,
    required this.focusMode,
  });

  final List<Skill> skills;
  final AppMode focusMode;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const SizedBox(height: 12);
    }

    final visibleSkills = skills.take(3).toList();
    final extraCount = skills.length - visibleSkills.length;

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
  });

  final DateTime selectedDay;
  final int proofCount;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              const SizedBox(height: 3),
              Text(
                proofCount == 1
                    ? '1 proof logged'
                    : '$proofCount proofs logged',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const Icon(Icons.event_note, color: Color(0xFF4C74FF)),
      ],
    );
  }
}
