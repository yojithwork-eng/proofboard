import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/mode_styles.dart';
import '../controllers/planned_session_controller.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/app_mode.dart';
import '../models/skill.dart';
import '../utils/skill_points_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/recap_sheet.dart';
import '../widgets/stat_card.dart';
import 'export_center_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  void _showRecap(BuildContext context, String title, String recap) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => RecapSheet(title: title, recap: recap),
    );
  }

  void _openExportCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ExportCenterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProofController, SkillController, SettingsController,
        PlannedSessionController>(
      builder: (
        context,
        controller,
        skillController,
        settings,
        plannedController,
        child,
      ) {
        final skills = skillController.skills;
        final counts = controller.skillCounts;
        final maxCount =
            counts.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);
        final activeSkills =
            skills.where((skill) => counts.containsKey(skill.id)).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _StatsHeader(
              totalProofs: controller.totalProofs,
              totalMinutes: controller.totalMinutes,
              totalSp: controller.totalSp,
              bestSkill: controller.bestSkill(skills),
              mode: settings.appMode,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.45 : 1.02,
                  children: [
                    StatCard(
                      label: 'Current streak',
                      value: '${controller.currentStreak} days',
                      icon: Icons.local_fire_department_outlined,
                      highlighted: true,
                    ),
                    StatCard(
                      label: 'Total SP',
                      value: '${controller.totalSp}',
                      icon: Icons.bolt,
                      color: const Color(0xFFF59E0B),
                      highlighted: true,
                    ),
                    StatCard(
                      label: 'SP this week',
                      value: '${controller.spThisWeek}',
                      icon: Icons.calendar_view_week_outlined,
                      color: const Color(0xFF2457FF),
                    ),
                    StatCard(
                      label: 'Total proofs',
                      value: '${controller.totalProofs}',
                      icon: Icons.task_alt,
                    ),
                    StatCard(
                      label: 'Total minutes',
                      value: '${controller.totalMinutes}',
                      icon: Icons.timer_outlined,
                      color: const Color(0xFF00A884),
                    ),
                    StatCard(
                      label: 'Active skills',
                      value: '${controller.activeSkills}',
                      icon: Icons.category_outlined,
                      color: const Color(0xFF7C3AED),
                    ),
                    StatCard(
                      label: 'Best skill',
                      value: controller.bestSkill(skills),
                      icon: Icons.emoji_events_outlined,
                      color: const Color(0xFFC2185B),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _RecapActions(
              onWeeklyRecap: () => _showRecap(
                context,
                'Weekly Recap',
                controller.weeklyRecap(skills),
              ),
              onShareSummary: () => _showRecap(
                context,
                'Share Summary',
                controller.shareRecap(skills),
              ),
              onOpenExportCenter: () => _openExportCenter(context),
            ),
            const SizedBox(height: 18),
            _SkillPointsPanel(
              totalSp: controller.totalSp,
              weekSp: controller.spThisWeek,
              monthSp: controller.spThisMonth,
              bestSkillBySp: SkillPointsUtils.bestSkillBySp(
                controller.proofs,
                skills,
              ),
              completedPlans: SkillPointsUtils.completedPlannedCount(
                plannedController.sessions,
              ),
              missedPlans: SkillPointsUtils.missedPlannedCount(
                plannedController.sessions,
              ),
              completionRate: SkillPointsUtils.completionRate(
                plannedController.sessions,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Skill Momentum',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'See which skills are growing fastest.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            if (counts.isEmpty)
              const EmptyState(
                icon: Icons.insights_outlined,
                title: 'Your dashboard is waiting',
                message:
                    'Log a proof and this screen turns into your skill-building command center.',
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.20
                            : 0.08,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: activeSkills
                      .map(
                        (skill) => _SkillProgressRow(
                          skill: skill,
                          count: counts[skill.id] ?? 0,
                          progress: (counts[skill.id] ?? 0) / maxCount,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({
    required this.totalProofs,
    required this.totalMinutes,
    required this.totalSp,
    required this.bestSkill,
    required this.mode,
  });

  final int totalProofs;
  final int totalMinutes;
  final int totalSp;
  final String bestSkill;
  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: modeGradientColors(mode).take(2).toList(),
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.query_stats, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            'Progress dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalProofs proofs, $totalMinutes minutes, $totalSp SP, strongest skill: $bestSkill.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecapActions extends StatelessWidget {
  const _RecapActions({
    required this.onWeeklyRecap,
    required this.onShareSummary,
    required this.onOpenExportCenter,
  });

  final VoidCallback onWeeklyRecap;
  final VoidCallback onShareSummary;
  final VoidCallback onOpenExportCenter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: onWeeklyRecap,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Weekly Recap'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onShareSummary,
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('Create Copyable Summary'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onOpenExportCenter,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Open Export Center'),
          ),
        ],
      ),
    );
  }
}

class _SkillPointsPanel extends StatelessWidget {
  const _SkillPointsPanel({
    required this.totalSp,
    required this.weekSp,
    required this.monthSp,
    required this.bestSkillBySp,
    required this.completedPlans,
    required this.missedPlans,
    required this.completionRate,
  });

  final int totalSp;
  final int weekSp;
  final int monthSp;
  final String bestSkillBySp;
  final int completedPlans;
  final int missedPlans;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completionPercent = (completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Skill Points',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SpTile(label: 'Total', value: '$totalSp SP'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SpTile(label: 'Week', value: '$weekSp SP'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SpTile(label: 'Month', value: '$monthSp SP'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SpInfoRow(label: 'Best skill by SP', value: bestSkillBySp),
          _SpInfoRow(label: 'Plans completed', value: '$completedPlans'),
          _SpInfoRow(label: 'Plans missed', value: '$missedPlans'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: completionRate.clamp(0, 1).toDouble(),
                    minHeight: 9,
                    color: colorScheme.primary,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completionPercent%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpTile extends StatelessWidget {
  const _SpTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
          ),
        ],
      ),
    );
  }
}

class _SpInfoRow extends StatelessWidget {
  const _SpInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _SkillProgressRow extends StatelessWidget {
  const _SkillProgressRow({
    required this.skill,
    required this.count,
    required this.progress,
  });

  final Skill skill;
  final int count;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = skillColor(skill);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(skillIcon(skill), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      count == 1 ? '1 proof logged' : '$count proofs logged',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.11),
            ),
          ),
        ],
      ),
    );
  }
}
