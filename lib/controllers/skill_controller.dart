import 'package:flutter/foundation.dart';

import '../models/skill.dart';
import '../services/skill_storage_service.dart';

class SkillController extends ChangeNotifier {
  SkillController(this._storageService);

  final SkillStorageService _storageService;

  List<Skill> _skills = List<Skill>.from(starterSkills);

  List<Skill> get skills => List<Skill>.unmodifiable(_skills);

  Future<void> loadSkills() async {
    _skills = await _storageService.loadSkills();
    notifyListeners();
  }

  Skill skillById(String skillId) {
    return _skills.firstWhere(
      (skill) => skill.id == skillId,
      orElse: () => _fallbackSkillFor(skillId),
    );
  }

  Future<void> addSkill(Skill skill) async {
    _skills = [..._skills, skill];
    await _storageService.saveSkills(_skills);
    notifyListeners();
  }

  Future<void> updateSkill(Skill updatedSkill) async {
    _skills = _skills
        .map((skill) => skill.id == updatedSkill.id ? updatedSkill : skill)
        .toList();
    await _storageService.saveSkills(_skills);
    notifyListeners();
  }

  Future<void> deleteSkill(String skillId) async {
    _skills = _skills.where((skill) => skill.id != skillId).toList();
    await _storageService.saveSkills(_skills);
    notifyListeners();
  }

  Skill _fallbackSkillFor(String skillId) {
    return starterSkills.firstWhere(
      (skill) => skill.id == skillId,
      orElse: () => const Skill(
        id: 'skill_other',
        name: 'Other',
        colorValue: defaultSkillColorValue,
        iconName: 'auto_awesome',
        mode: SkillMode.general,
      ),
    );
  }
}
