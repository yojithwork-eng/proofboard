import '../models/proof.dart';
import '../models/skill.dart';
import 'date_utils.dart';

class StatsUtils {
  static int totalMinutes(List<Proof> proofs) {
    return proofs.fold(0, (sum, proof) => sum + proof.minutes);
  }

  static Map<String, int> skillCounts(List<Proof> proofs) {
    final counts = <String, int>{};

    for (final proof in proofs) {
      counts.update(proof.skillId, (count) => count + 1, ifAbsent: () => 1);
    }

    return counts;
  }

  static int activeSkillCount(List<Proof> proofs) {
    return skillCounts(proofs).length;
  }

  static int currentStreak(List<Proof> proofs) {
    if (proofs.isEmpty) {
      return 0;
    }

    final proofDays = proofs
        .map((proof) => ProofDateUtils.dateOnly(proof.date))
        .map((date) => date.millisecondsSinceEpoch)
        .toSet();

    final today = ProofDateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime cursor;
    if (proofDays.contains(today.millisecondsSinceEpoch)) {
      cursor = today;
    } else if (proofDays.contains(yesterday.millisecondsSinceEpoch)) {
      cursor = yesterday;
    } else {
      return 0;
    }

    var streak = 0;
    while (proofDays.contains(cursor.millisecondsSinceEpoch)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static String bestSkillName(List<Proof> proofs, List<Skill> skills) {
    final best = bestSkillId(proofs);
    if (best == null) {
      return 'None yet';
    }

    return _skillNameFor(best, skills);
  }

  static String? bestSkillId(List<Proof> proofs) {
    final counts = skillCounts(proofs);
    if (counts.isEmpty) {
      return null;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  static List<Proof> proofsFromLastSevenDays(List<Proof> proofs) {
    final today = ProofDateUtils.dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));
    return proofs
        .where(
          (proof) => !proof.date.isBefore(start) && !proof.date.isAfter(today),
        )
        .toList();
  }

  static String weeklyRecap(List<Proof> proofs, List<Skill> skills) {
    final weeklyProofs = proofsFromLastSevenDays(proofs);
    if (weeklyProofs.isEmpty) {
      return 'No proofs logged this week yet. Add one small proof today and start building momentum.';
    }

    final skillNames = _skillNamesFor(weeklyProofs, skills);
    final strongest = bestSkillName(weeklyProofs, skills);
    final minutes = totalMinutes(weeklyProofs);

    return 'This week you logged ${weeklyProofs.length} proofs across $skillNames for a total of $minutes minutes. Your strongest skill was $strongest. Keep building proof one day at a time.';
  }

  static String shareRecap(List<Proof> proofs, List<Skill> skills) {
    final weeklyProofs = proofsFromLastSevenDays(proofs);
    if (weeklyProofs.isEmpty) {
      return 'This week on ProofBoard, I am starting my proof-of-work habit. Small steps, real proof.';
    }

    final skillNames = _skillNamesFor(weeklyProofs, skills);
    final minutes = totalMinutes(weeklyProofs);

    return 'This week on ProofBoard, I logged ${weeklyProofs.length} proofs of work across $skillNames. Total focused time: $minutes minutes. Small steps, real proof.';
  }

  static String _skillNamesFor(List<Proof> proofs, List<Skill> skills) {
    final counts = skillCounts(proofs);
    final names =
        counts.keys.map((skillId) => _skillNameFor(skillId, skills)).toList();

    if (names.isEmpty) {
      return 'no skills yet';
    }

    if (names.length == 1) {
      return names.first;
    }

    if (names.length == 2) {
      return '${names.first} and ${names.last}';
    }

    return '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}';
  }

  static String _skillNameFor(String skillId, List<Skill> skills) {
    return skills
        .firstWhere(
          (skill) => skill.id == skillId,
          orElse: () => starterSkills.firstWhere(
            (skill) => skill.id == skillId,
            orElse: () => const Skill(
              id: 'skill_other',
              name: 'Other',
              colorValue: defaultSkillColorValue,
              iconName: 'auto_awesome',
              mode: SkillMode.general,
            ),
          ),
        )
        .name;
  }
}
