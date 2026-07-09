import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../controllers/proof_controller.dart';
import '../models/proof.dart';
import '../widgets/empty_state.dart';
import '../widgets/recap_sheet.dart';
import '../widgets/stat_card.dart';

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
            _StatsHeader(
              totalProofs: controller.totalProofs,
              totalMinutes: controller.totalMinutes,
              bestCategory: controller.bestCategory,
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
                      label: 'Active categories',
                      value: '${controller.activeCategories}',
                      icon: Icons.category_outlined,
                      color: const Color(0xFF7C3AED),
                    ),
                    StatCard(
                      label: 'Best category',
                      value: controller.bestCategory,
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
                controller.weeklyRecap(),
              ),
              onShareSummary: () => _showRecap(
                context,
                'Share Summary',
                controller.shareRecap(),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Category Momentum',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'See where your proof stack is growing fastest.',
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
                  children: proofCategories
                      .where((category) => counts.containsKey(category))
                      .map(
                        (category) => _CategoryProgressRow(
                          category: category,
                          count: counts[category] ?? 0,
                          progress: (counts[category] ?? 0) / maxCount,
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
    required this.bestCategory,
  });

  final int totalProofs;
  final int totalMinutes;
  final String bestCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07152F), Color(0xFF123B8E)],
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
            '$totalProofs proofs, $totalMinutes minutes, strongest lane: $bestCategory.',
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
  });

  final VoidCallback onWeeklyRecap;
  final VoidCallback onShareSummary;

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
        ],
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
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
                child: Icon(categoryIcon(category), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
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
