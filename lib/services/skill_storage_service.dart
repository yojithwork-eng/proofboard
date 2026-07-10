import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/skill.dart';

class SkillStorageService {
  static const String _skillsKey = 'proofboard_skills';

  Future<List<Skill>> loadSkills() async {
    final preferences = await SharedPreferences.getInstance();
    final rawJson = preferences.getString(_skillsKey);

    if (rawJson == null || rawJson.isEmpty) {
      return List<Skill>.from(starterSkills);
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        return List<Skill>.from(starterSkills);
      }

      final skills = decoded
          .whereType<Map<String, dynamic>>()
          .map(Skill.fromJson)
          .where((skill) => skill.id.isNotEmpty && skill.name.trim().isNotEmpty)
          .toList();

      return skills.isEmpty ? List<Skill>.from(starterSkills) : skills;
    } catch (_) {
      return List<Skill>.from(starterSkills);
    }
  }

  Future<void> saveSkills(List<Skill> skills) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      skills.map((skill) => skill.toJson()).toList(),
    );

    await preferences.setString(_skillsKey, encoded);
  }
}
