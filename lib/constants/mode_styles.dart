import 'package:flutter/material.dart';

import '../models/app_mode.dart';
import '../models/skill.dart';
import 'categories.dart';

class SuggestedSkill {
  const SuggestedSkill({
    required this.name,
    required this.colorValue,
    required this.iconName,
    required this.mode,
  });

  final String name;
  final int colorValue;
  final String iconName;
  final SkillMode mode;

  Skill toSkill() {
    return Skill(
      id: '${Skill.idForName(name)}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      colorValue: colorValue,
      iconName: iconName,
      mode: mode,
    );
  }
}

Color modeAccentColor(AppMode mode) {
  return switch (mode) {
    AppMode.general => const Color(0xFF7C3AED),
    AppMode.productivity => const Color(0xFF1D63FF),
    AppMode.selfImprovement => const Color(0xFF0E9F6E),
  };
}

Color modeSecondaryColor(AppMode mode) {
  return switch (mode) {
    AppMode.general => const Color(0xFFFF8A3D),
    AppMode.productivity => const Color(0xFF00C2FF),
    AppMode.selfImprovement => const Color(0xFF7AC943),
  };
}

List<Color> modeGradientColors(AppMode mode) {
  return switch (mode) {
    AppMode.general => const [
        Color(0xFF07152F),
        Color(0xFF4C1D95),
        Color(0xFFFF8A3D),
      ],
    AppMode.productivity => const [
        Color(0xFF041326),
        Color(0xFF123B8E),
        Color(0xFF1D63FF),
      ],
    AppMode.selfImprovement => const [
        Color(0xFF061A16),
        Color(0xFF087F5B),
        Color(0xFF22C55E),
      ],
  };
}

List<SuggestedSkill> suggestedSkillsForMode(AppMode mode) {
  return switch (mode) {
    AppMode.general => const [
        SuggestedSkill(
          name: 'Coding',
          colorValue: 0xFF3157D5,
          iconName: 'code',
          mode: SkillMode.general,
        ),
        SuggestedSkill(
          name: 'CAD',
          colorValue: 0xFF7C3AED,
          iconName: 'architecture',
          mode: SkillMode.general,
        ),
        SuggestedSkill(
          name: 'Robotics',
          colorValue: 0xFF00897B,
          iconName: 'robotics',
          mode: SkillMode.general,
        ),
        SuggestedSkill(
          name: 'Reading',
          colorValue: 0xFF2E7D32,
          iconName: 'book',
          mode: SkillMode.general,
        ),
      ],
    AppMode.productivity => const [
        SuggestedSkill(
          name: 'Deep Work',
          colorValue: 0xFF2457FF,
          iconName: 'bolt',
          mode: SkillMode.productivity,
        ),
        SuggestedSkill(
          name: 'Studying',
          colorValue: 0xFF1565C0,
          iconName: 'school',
          mode: SkillMode.productivity,
        ),
        SuggestedSkill(
          name: 'Projects',
          colorValue: 0xFF7C3AED,
          iconName: 'build',
          mode: SkillMode.productivity,
        ),
        SuggestedSkill(
          name: 'Job Applications',
          colorValue: 0xFF546E7A,
          iconName: 'work',
          mode: SkillMode.productivity,
        ),
        SuggestedSkill(
          name: 'Networking',
          colorValue: 0xFFC2185B,
          iconName: 'groups',
          mode: SkillMode.productivity,
        ),
      ],
    AppMode.selfImprovement => const [
        SuggestedSkill(
          name: 'Sleep',
          colorValue: 0xFF536DFE,
          iconName: 'sleep',
          mode: SkillMode.selfImprovement,
        ),
        SuggestedSkill(
          name: 'Exercise',
          colorValue: 0xFFE65100,
          iconName: 'fitness',
          mode: SkillMode.selfImprovement,
        ),
        SuggestedSkill(
          name: 'Diet',
          colorValue: 0xFF2E7D32,
          iconName: 'restaurant',
          mode: SkillMode.selfImprovement,
        ),
        SuggestedSkill(
          name: 'Hydration',
          colorValue: 0xFF00ACC1,
          iconName: 'water',
          mode: SkillMode.selfImprovement,
        ),
        SuggestedSkill(
          name: 'Journaling',
          colorValue: 0xFFAD1457,
          iconName: 'journal',
          mode: SkillMode.selfImprovement,
        ),
      ],
  };
}

bool skillExistsByName(List<Skill> skills, String name) {
  final normalizedName = name.trim().toLowerCase();
  return skills
      .any((skill) => skill.name.trim().toLowerCase() == normalizedName);
}

bool skillFitsAppMode(Skill skill, AppMode mode) {
  if (skill.mode == mode.skillMode) {
    return true;
  }

  final suggestedNames = suggestedSkillsForMode(mode)
      .map((suggestion) => suggestion.name.trim().toLowerCase())
      .toSet();
  return suggestedNames.contains(skill.name.trim().toLowerCase());
}

Color suggestedSkillColor(SuggestedSkill skill) {
  return Color(skill.colorValue);
}

IconData suggestedSkillIcon(SuggestedSkill skill) {
  return iconForSkillName(skill.iconName);
}
