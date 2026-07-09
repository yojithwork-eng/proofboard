import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../controllers/proof_controller.dart';
import '../models/proof.dart';
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
    return Consumer<ProofController>(
      builder: (context, controller, child) {
        final counts = controller.categoryCounts;
        final maxCount =
            counts.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _HomeHero(
              streak: controller.currentStreak,
              totalProofs: controller.totalProofs,
              totalMinutes: controller.totalMinutes,
              onOpenSettings: onOpenSettings,
            ),
            const SizedBox(height: 16),
            _MissionCard(onAddProof: onAddProof),
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
                      child: ProofCard(proof: proof),
                    ),
                  ),
            if (controller.proofs.isNotEmpty) ...[
              const SizedBox(height: 14),
              const _SectionTitle(
                title: 'Skill Lanes',
                subtitle: 'Your proof stack by category',
              ),
              const SizedBox(height: 12),
              Column(
                children: proofCategories
                    .where((category) => counts.containsKey(category))
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CategorySummaryCard(
                          category: category,
                          count: counts[category] ?? 0,
                          progress: (counts[category] ?? 0) / maxCount,
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
    required this.onOpenSettings,
  });

  final int streak;
  final int totalProofs;
  final int totalMinutes;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF07152F),
            Color(0xFF123B8E),
            Color(0xFF2457FF),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2457FF).withValues(alpha: 0.24),
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
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const Spacer(),
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
            'Build your proof stack',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Small work today. Real portfolio tomorrow.',
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
  const _MissionCard({required this.onAddProof});

  final VoidCallback onAddProof;

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF2457FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              color: Color(0xFF2457FF),
            ),
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
                  'Capture one focused proof before the day ends.',
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

class _CategorySummaryCard extends StatelessWidget {
  const _CategorySummaryCard({
    required this.category,
    required this.count,
    required this.progress,
  });

  final ProofCategory category;
  final int count;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);

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
            child: Icon(categoryIcon(category), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.displayName,
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
