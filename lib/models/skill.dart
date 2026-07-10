enum SkillMode {
  general,
  productivity,
  selfImprovement,
}

extension SkillModeDisplay on SkillMode {
  String get displayName {
    return switch (this) {
      SkillMode.general => 'General',
      SkillMode.productivity => 'Productivity',
      SkillMode.selfImprovement => 'Self Improvement',
    };
  }

  static SkillMode fromName(String? name) {
    return SkillMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => SkillMode.general,
    );
  }
}

class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
    required this.mode,
  });

  final String id;
  final String name;
  final int colorValue;
  final String iconName;
  final SkillMode mode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconName': iconName,
      'mode': mode.name,
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Skill',
      colorValue: json['colorValue'] is int
          ? json['colorValue'] as int
          : defaultSkillColorValue,
      iconName: json['iconName'] as String? ?? 'auto_awesome',
      mode: SkillModeDisplay.fromName(json['mode'] as String?),
    );
  }

  Skill copyWith({
    String? name,
    int? colorValue,
    String? iconName,
    SkillMode? mode,
  }) {
    return Skill(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      mode: mode ?? this.mode,
    );
  }

  static String idForName(String name) {
    final normalized = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return 'skill_${normalized.isEmpty ? 'custom' : normalized}';
  }

  static String idForLegacyCategory(String? categoryName) {
    return switch (categoryName) {
      'coding' => 'skill_coding',
      'cad' => 'skill_cad',
      'robotics' => 'skill_robotics',
      'gym' => 'skill_gym',
      'studying' => 'skill_studying',
      'networking' => 'skill_networking',
      'reading' => 'skill_reading',
      _ => 'skill_other',
    };
  }
}

const int defaultSkillColorValue = 0xFF4C74FF;

const starterSkills = [
  Skill(
    id: 'skill_coding',
    name: 'Coding',
    colorValue: 0xFF3157D5,
    iconName: 'code',
    mode: SkillMode.general,
  ),
  Skill(
    id: 'skill_cad',
    name: 'CAD',
    colorValue: 0xFF7C3AED,
    iconName: 'architecture',
    mode: SkillMode.general,
  ),
  Skill(
    id: 'skill_robotics',
    name: 'Robotics',
    colorValue: 0xFF00897B,
    iconName: 'robotics',
    mode: SkillMode.general,
  ),
  Skill(
    id: 'skill_gym',
    name: 'Gym',
    colorValue: 0xFFE65100,
    iconName: 'fitness',
    mode: SkillMode.general,
  ),
  Skill(
    id: 'skill_studying',
    name: 'Studying',
    colorValue: 0xFF1565C0,
    iconName: 'school',
    mode: SkillMode.general,
  ),
  Skill(
    id: 'skill_reading',
    name: 'Reading',
    colorValue: 0xFF2E7D32,
    iconName: 'book',
    mode: SkillMode.general,
  ),
  Skill(
    id: 'skill_deep_work',
    name: 'Deep Work',
    colorValue: 0xFF2457FF,
    iconName: 'bolt',
    mode: SkillMode.productivity,
  ),
  Skill(
    id: 'skill_projects',
    name: 'Projects',
    colorValue: 0xFF7C3AED,
    iconName: 'build',
    mode: SkillMode.productivity,
  ),
  Skill(
    id: 'skill_exam_prep',
    name: 'Exam Prep',
    colorValue: 0xFFC2185B,
    iconName: 'school',
    mode: SkillMode.productivity,
  ),
  Skill(
    id: 'skill_job_applications',
    name: 'Job Applications',
    colorValue: 0xFF546E7A,
    iconName: 'work',
    mode: SkillMode.productivity,
  ),
  Skill(
    id: 'skill_networking',
    name: 'Networking',
    colorValue: 0xFFC2185B,
    iconName: 'groups',
    mode: SkillMode.productivity,
  ),
  Skill(
    id: 'skill_sleep',
    name: 'Sleep',
    colorValue: 0xFF536DFE,
    iconName: 'sleep',
    mode: SkillMode.selfImprovement,
  ),
  Skill(
    id: 'skill_exercise',
    name: 'Exercise',
    colorValue: 0xFFE65100,
    iconName: 'fitness',
    mode: SkillMode.selfImprovement,
  ),
  Skill(
    id: 'skill_diet',
    name: 'Diet',
    colorValue: 0xFF2E7D32,
    iconName: 'restaurant',
    mode: SkillMode.selfImprovement,
  ),
  Skill(
    id: 'skill_hydration',
    name: 'Hydration',
    colorValue: 0xFF00ACC1,
    iconName: 'water',
    mode: SkillMode.selfImprovement,
  ),
  Skill(
    id: 'skill_walking',
    name: 'Walking',
    colorValue: 0xFF00897B,
    iconName: 'walking',
    mode: SkillMode.selfImprovement,
  ),
  Skill(
    id: 'skill_journaling',
    name: 'Journaling',
    colorValue: 0xFFAD1457,
    iconName: 'journal',
    mode: SkillMode.selfImprovement,
  ),
  Skill(
    id: 'skill_other',
    name: 'Other',
    colorValue: 0xFF546E7A,
    iconName: 'auto_awesome',
    mode: SkillMode.general,
  ),
];
