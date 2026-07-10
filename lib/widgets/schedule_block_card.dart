import 'package:flutter/material.dart';

import '../constants/categories.dart';
import '../models/skill.dart';

class ScheduleBlockCard extends StatelessWidget {
  const ScheduleBlockCard({
    super.key,
    required this.skill,
    required this.title,
    required this.timeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.icon,
    this.subtitle,
    this.spLabel,
    this.onPrimary,
    this.primaryLabel,
    this.onEdit,
    this.onDelete,
    this.muted = false,
  });

  final Skill skill;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final String statusLabel;
  final Color statusColor;
  final IconData icon;
  final String? spLabel;
  final VoidCallback? onPrimary;
  final String? primaryLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = muted ? colorScheme.onSurfaceVariant : skillColor(skill);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: muted
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.46)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: muted ? 0.12 : 0.20),
        ),
        boxShadow: [
          if (!muted)
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: muted ? 0.36 : 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(icon, color: accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: muted
                                            ? colorScheme.onSurfaceVariant
                                            : colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _ChipPill(
                            label: statusLabel,
                            icon: Icons.circle,
                            color: statusColor,
                          ),
                          if (spLabel != null)
                            _ChipPill(
                              label: spLabel!,
                              icon: Icons.bolt,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                      if (onPrimary != null ||
                          onEdit != null ||
                          onDelete != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (onPrimary != null)
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: onPrimary,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: Text(primaryLabel ?? 'Log Proof'),
                                ),
                              ),
                            if (onPrimary != null &&
                                (onEdit != null || onDelete != null))
                              const SizedBox(width: 8),
                            if (onEdit != null)
                              IconButton.filledTonal(
                                tooltip: 'Edit',
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            if (onDelete != null)
                              IconButton.filledTonal(
                                tooltip: 'Delete',
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete_outline),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
