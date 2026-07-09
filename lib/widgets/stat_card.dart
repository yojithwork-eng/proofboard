import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? colorScheme.primary;
    final textColor = highlighted ? Colors.white : colorScheme.onSurface;
    final mutedTextColor = highlighted
        ? Colors.white.withValues(alpha: 0.76)
        : colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        gradient: highlighted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF07152F),
                  Color(0xFF123B8E),
                  Color(0xFF2457FF),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.68),
                ],
              ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted
              ? Colors.white.withValues(alpha: 0.12)
              : colorScheme.onSurface.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: (highlighted ? accent : Colors.black).withValues(
              alpha: highlighted
                  ? 0.22
                  : isDark
                      ? 0.22
                      : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: highlighted
                    ? Colors.white.withValues(alpha: 0.14)
                    : accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: highlighted ? Colors.white : accent,
                size: 22,
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: mutedTextColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
