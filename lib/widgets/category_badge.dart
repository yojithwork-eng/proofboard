import 'package:flutter/material.dart';

import '../constants/categories.dart';
import '../models/skill.dart';

class SkillBadge extends StatelessWidget {
  const SkillBadge({
    super.key,
    required this.skill,
    this.compact = false,
  });

  final Skill skill;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = skillColor(skill);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(skillIcon(skill), size: compact ? 14 : 16, color: color),
          const SizedBox(width: 6),
          Text(
            skill.name,
            style: TextStyle(
              color: color,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
