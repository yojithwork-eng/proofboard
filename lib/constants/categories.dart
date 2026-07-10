import 'package:flutter/material.dart';

import '../models/skill.dart';

const skillColorChoices = [
  SkillColorChoice('Purple', 0xFF7C3AED),
  SkillColorChoice('Orange', 0xFFE65100),
  SkillColorChoice('Blue', 0xFF3157D5),
  SkillColorChoice('Green', 0xFF2E7D32),
  SkillColorChoice('Red', 0xFFE53935),
  SkillColorChoice('Pink', 0xFFC2185B),
  SkillColorChoice('Teal', 0xFF00897B),
  SkillColorChoice('Yellow', 0xFFF9A825),
  SkillColorChoice('Gray', 0xFF546E7A),
];

class SkillColorChoice {
  const SkillColorChoice(this.name, this.colorValue);

  final String name;
  final int colorValue;
}

Color skillColor(Skill skill) {
  return Color(skill.colorValue);
}

IconData skillIcon(Skill skill) {
  return iconForSkillName(skill.iconName);
}

IconData iconForSkillName(String iconName) {
  return switch (iconName) {
    'code' => Icons.code,
    'architecture' => Icons.architecture,
    'robotics' => Icons.precision_manufacturing,
    'fitness' => Icons.fitness_center,
    'school' => Icons.school,
    'groups' => Icons.groups,
    'book' => Icons.menu_book,
    'bolt' => Icons.bolt,
    'build' => Icons.construction,
    'work' => Icons.work_outline,
    'sleep' => Icons.bedtime_outlined,
    'restaurant' => Icons.restaurant,
    'water' => Icons.water_drop_outlined,
    'walking' => Icons.directions_walk,
    'journal' => Icons.edit_note,
    _ => Icons.auto_awesome,
  };
}

String iconNameForSkillName(String skillName) {
  final normalized = skillName.trim().toLowerCase();
  if (normalized.contains('code')) return 'code';
  if (normalized.contains('cad')) return 'architecture';
  if (normalized.contains('robot')) return 'robotics';
  if (normalized.contains('gym') || normalized.contains('exercise')) {
    return 'fitness';
  }
  if (normalized.contains('study') || normalized.contains('exam')) {
    return 'school';
  }
  if (normalized.contains('network')) return 'groups';
  if (normalized.contains('read')) return 'book';
  if (normalized.contains('sleep')) return 'sleep';
  if (normalized.contains('diet')) return 'restaurant';
  if (normalized.contains('water') || normalized.contains('hydration')) {
    return 'water';
  }
  if (normalized.contains('walk')) return 'walking';
  if (normalized.contains('journal')) return 'journal';
  if (normalized.contains('project')) return 'build';
  if (normalized.contains('job')) return 'work';
  if (normalized.contains('deep')) return 'bolt';
  return 'auto_awesome';
}
