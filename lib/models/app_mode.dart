import 'package:flutter/material.dart';

import 'skill.dart';

enum AppMode {
  general,
  productivity,
  selfImprovement,
}

extension AppModeDisplay on AppMode {
  String get displayName {
    return switch (this) {
      AppMode.general => 'General',
      AppMode.productivity => 'Productivity',
      AppMode.selfImprovement => 'Self-Improvement',
    };
  }

  String get shortLabel {
    return switch (this) {
      AppMode.general => 'General',
      AppMode.productivity => 'Focus',
      AppMode.selfImprovement => 'Growth',
    };
  }

  String get activationTitle {
    return switch (this) {
      AppMode.general => 'ProofBoard Mode Activated',
      AppMode.productivity => 'Productivity Mode Activated',
      AppMode.selfImprovement => 'Self-Improvement Mode Activated',
    };
  }

  String get focusLine {
    return switch (this) {
      AppMode.general => 'General proof-of-work tracking',
      AppMode.productivity => 'Study, deep work, projects, and career progress',
      AppMode.selfImprovement => 'Health, habits, lifestyle, and discipline',
    };
  }

  String get homeHeadline {
    return switch (this) {
      AppMode.general => 'Build your proof stack',
      AppMode.productivity => 'Lock in your focus stack',
      AppMode.selfImprovement => 'Grow your daily discipline',
    };
  }

  String get homeSubtitle {
    return switch (this) {
      AppMode.general => 'Small work today. Real portfolio tomorrow.',
      AppMode.productivity =>
        'Focused sessions today. Visible progress tomorrow.',
      AppMode.selfImprovement =>
        'Tiny habits today. Stronger systems tomorrow.',
    };
  }

  String get missionText {
    return switch (this) {
      AppMode.general => 'Capture one focused proof before the day ends.',
      AppMode.productivity =>
        'Log one focused block that moved the work forward.',
      AppMode.selfImprovement =>
        'Record one habit win that supports the next version of you.',
    };
  }

  SkillMode get skillMode {
    return switch (this) {
      AppMode.general => SkillMode.general,
      AppMode.productivity => SkillMode.productivity,
      AppMode.selfImprovement => SkillMode.selfImprovement,
    };
  }

  IconData get icon {
    return switch (this) {
      AppMode.general => Icons.rocket_launch_outlined,
      AppMode.productivity => Icons.bolt,
      AppMode.selfImprovement => Icons.eco_outlined,
    };
  }

  static AppMode fromName(String? name) {
    return AppMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppMode.general,
    );
  }
}
