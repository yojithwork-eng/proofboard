import 'package:flutter/foundation.dart';

import '../models/proof.dart';
import '../models/skill.dart';
import '../services/proof_storage_service.dart';
import '../utils/date_utils.dart';
import '../utils/skill_points_utils.dart';
import '../utils/stats_utils.dart';

class ProofController extends ChangeNotifier {
  ProofController(this._storageService);

  final ProofStorageService _storageService;

  List<Proof> _proofs = [];
  bool _isLoading = false;

  List<Proof> get proofs {
    final sorted = List<Proof>.from(_proofs);
    sorted.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) {
        return dateComparison;
      }

      final aTime = ProofDateUtils.minutesFromTimeString(a.startTime) ?? 1440;
      final bTime = ProofDateUtils.minutesFromTimeString(b.startTime) ?? 1440;
      final timeComparison = bTime.compareTo(aTime);
      if (timeComparison != 0) {
        return timeComparison;
      }

      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  bool get isLoading => _isLoading;

  int get totalProofs => _proofs.length;

  int get totalMinutes => StatsUtils.totalMinutes(_proofs);

  int get totalSp => SkillPointsUtils.totalSp(_proofs);

  int get spToday => SkillPointsUtils.spToday(_proofs);

  int get spThisWeek => SkillPointsUtils.spThisWeek(_proofs);

  int get spThisMonth => SkillPointsUtils.spThisMonth(_proofs);

  int get activeSkills => StatsUtils.activeSkillCount(_proofs);

  int get currentStreak => StatsUtils.currentStreak(_proofs);

  String bestSkill(List<Skill> skills) =>
      StatsUtils.bestSkillName(_proofs, skills);

  Map<String, int> get skillCounts => StatsUtils.skillCounts(_proofs);

  Map<String, int> get spBySkill => SkillPointsUtils.spBySkill(_proofs);

  Future<void> loadProofs() async {
    _isLoading = true;
    notifyListeners();

    _proofs = await _storageService.loadProofs();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProof(Proof proof) async {
    _proofs = [proof, ..._proofs];
    await _storageService.saveProofs(_proofs);
    notifyListeners();
  }

  Future<void> updateProof(Proof updatedProof) async {
    _proofs = _proofs
        .map((proof) => proof.id == updatedProof.id ? updatedProof : proof)
        .toList();
    await _storageService.saveProofs(_proofs);
    notifyListeners();
  }

  Future<Proof?> deleteProof(String id) async {
    Proof? deletedProof;
    for (final proof in _proofs) {
      if (proof.id == id) {
        deletedProof = proof;
        break;
      }
    }

    _proofs = _proofs.where((proof) => proof.id != id).toList();
    await _storageService.saveProofs(_proofs);
    notifyListeners();
    return deletedProof;
  }

  Future<void> clearProofs() async {
    _proofs = [];
    await _storageService.clearProofs();
    notifyListeners();
  }

  bool isSkillUsed(String skillId) {
    return _proofs.any((proof) => proof.skillId == skillId);
  }

  String weeklyRecap(List<Skill> skills) {
    return StatsUtils.weeklyRecap(_proofs, skills);
  }

  String shareRecap(List<Skill> skills) {
    return StatsUtils.shareRecap(_proofs, skills);
  }
}
