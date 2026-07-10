import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../constants/mode_styles.dart';
import '../controllers/proof_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/skill_controller.dart';
import '../models/app_mode.dart';
import '../models/resource.dart';
import '../models/skill.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/proof_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onAddProof,
    required this.onOpenSettings,
  });

  final VoidCallback onAddProof;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProofController, SkillController, SettingsController>(
      builder: (context, controller, skillController, settings, child) {
        final appMode = settings.appMode;
        final counts = controller.skillCounts;
        final maxCount =
            counts.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);
        final activeSkills = skillController.skills
            .where((skill) => counts.containsKey(skill.id))
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _HomeHero(
              streak: controller.currentStreak,
              totalProofs: controller.totalProofs,
              totalMinutes: controller.totalMinutes,
              mode: appMode,
              onOpenSettings: onOpenSettings,
            ),
            const SizedBox(height: 16),
            _MissionCard(mode: appMode, onAddProof: onAddProof),
            const SizedBox(height: 18),
            _SuggestedSkillsSection(
              mode: appMode,
              skills: skillController.skills,
              onAddSkill: (suggestion) async {
                await skillController.addSkill(suggestion.toSkill());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${suggestion.name} added')),
                  );
                }
              },
            ),
            const SizedBox(height: 18),
            _ResourcesSection(
              mode: appMode,
              skills: skillController.skills,
            ),
            const SizedBox(height: 26),
            const _SectionTitle(
              title: 'Recent Proofs',
              subtitle: 'Latest work added to your stack',
            ),
            const SizedBox(height: 12),
            if (controller.proofs.isEmpty)
              EmptyState(
                icon: Icons.bolt_outlined,
                title: 'Start your public proof stack',
                message:
                    'Log one small win today. A lesson, sketch, workout, page, or build session is enough to start momentum.',
                action: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAddProof,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Log First Proof'),
                  ),
                ),
              )
            else
              ...controller.proofs.take(3).map(
                    (proof) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProofCard(
                        proof: proof,
                        skill: skillController.skillById(proof.skillId),
                      ),
                    ),
                  ),
            if (controller.proofs.isNotEmpty) ...[
              const SizedBox(height: 14),
              const _SectionTitle(
                title: 'Skill Lanes',
                subtitle: 'Your proof stack by skill',
              ),
              const SizedBox(height: 12),
              Column(
                children: activeSkills
                    .map(
                      (skill) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SkillSummaryCard(
                          skill: skill,
                          count: counts[skill.id] ?? 0,
                          progress: (counts[skill.id] ?? 0) / maxCount,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.streak,
    required this.totalProofs,
    required this.totalMinutes,
    required this.mode,
    required this.onOpenSettings,
  });

  final int streak;
  final int totalProofs;
  final int totalMinutes;
  final AppMode mode;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final gradientColors = modeGradientColors(mode);
    final accent = modeAccentColor(mode);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        ProofDateUtils.todayLabel(),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${mode.shortLabel} mode',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Open settings',
                onPressed: onOpenSettings,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            mode.homeHeadline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            mode.homeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _HeroMetric(
                value: '$streak',
                label: 'day streak',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(width: 10),
              _HeroMetric(
                value: '$totalProofs',
                label: 'proofs',
                icon: Icons.verified_outlined,
              ),
              const SizedBox(width: 10),
              _HeroMetric(
                value: '$totalMinutes',
                label: 'minutes',
                icon: Icons.timer_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mode,
    required this.onAddProof,
  });

  final AppMode mode;
  final VoidCallback onAddProof;

  @override
  Widget build(BuildContext context) {
    final accent = modeAccentColor(mode);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.20 : 0.08,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(mode.icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s mission',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  mode.missionText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onAddProof,
            style: FilledButton.styleFrom(
              minimumSize: const Size(110, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Add Proof'),
          ),
        ],
      ),
    );
  }
}

class _SuggestedSkillsSection extends StatelessWidget {
  const _SuggestedSkillsSection({
    required this.mode,
    required this.skills,
    required this.onAddSkill,
  });

  final AppMode mode;
  final List<Skill> skills;
  final Future<void> Function(SuggestedSkill skill) onAddSkill;

  @override
  Widget build(BuildContext context) {
    final suggestions = suggestedSkillsForMode(mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: '${mode.displayName} Skills',
          subtitle: 'Add useful lanes for this operating mode',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              final exists = skillExistsByName(skills, suggestion.name);

              return _SuggestedSkillCard(
                suggestion: suggestion,
                exists: exists,
                onAdd: () => onAddSkill(suggestion),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SuggestedSkillCard extends StatelessWidget {
  const _SuggestedSkillCard({
    required this.suggestion,
    required this.exists,
    required this.onAdd,
  });

  final SuggestedSkill suggestion;
  final bool exists;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = suggestedSkillColor(suggestion);

    return Container(
      width: 164,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(suggestedSkillIcon(suggestion), color: color),
              ),
              const Spacer(),
              Icon(
                exists ? Icons.check_circle : Icons.add_circle_outline,
                color: exists ? color : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          const Spacer(),
          Text(
            suggestion.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: exists
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Added'),
                  )
                : FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Add'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResourcesSection extends StatelessWidget {
  const _ResourcesSection({
    required this.mode,
    required this.skills,
  });

  final AppMode mode;
  final List<Skill> skills;

  @override
  Widget build(BuildContext context) {
    final skillNames =
        skills.map((skill) => skill.name.trim().toLowerCase()).toSet();
    final modeResources = resourcesForMode(mode);
    final matchingResources = modeResources
        .where(
          (resource) =>
              skillNames.contains(resource.relatedSkillName.toLowerCase()),
        )
        .toList();
    final resources =
        (matchingResources.isEmpty ? modeResources : matchingResources)
            .take(3)
            .toList();

    if (resources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Helpful Resources',
          subtitle: 'Static starter links for your current mode',
        ),
        const SizedBox(height: 12),
        ...resources.map(
          (resource) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ResourceCard(resource: resource),
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final Resource resource;

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: resource.url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource link copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.menu_book_outlined, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  resource.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            tooltip: 'Copy resource link',
            onPressed: () => _copyLink(context),
            icon: const Icon(Icons.copy, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const Icon(Icons.stacked_line_chart, color: Color(0xFF2457FF)),
      ],
    );
  }
}

class _SkillSummaryCard extends StatelessWidget {
  const _SkillSummaryCard({
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(skillIcon(skill), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1).toDouble(),
                    minHeight: 7,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
              ),
              Text(
                count == 1 ? 'proof' : 'proofs',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
