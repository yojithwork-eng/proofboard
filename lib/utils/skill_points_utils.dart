import '../models/planned_session.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import 'date_utils.dart';
import 'stats_utils.dart';

class SkillPointsUtils {
  static const int minutesPerSp = 15;
  static const int completedPlanBonus = 5;
  static const double completionThreshold = 0.80;

  static int baseSpForMinutes(int minutes) {
    return minutes ~/ minutesPerSp;
  }

  static bool completesPlan({
    required int completedMinutes,
    required int plannedMinutes,
  }) {
    if (plannedMinutes <= 0) {
      return false;
    }

    return completedMinutes >= (plannedMinutes * completionThreshold).ceil();
  }

  static PlannedSessionStatus statusForProof({
    required int completedMinutes,
    required PlannedSession plannedSession,
  }) {
    return completesPlan(
      completedMinutes: completedMinutes,
      plannedMinutes: plannedSession.plannedMinutes,
    )
        ? PlannedSessionStatus.completed
        : PlannedSessionStatus.partiallyCompleted;
  }

  static int bonusForProof({
    required int completedMinutes,
    PlannedSession? plannedSession,
  }) {
    if (plannedSession == null) {
      return 0;
    }

    return completesPlan(
      completedMinutes: completedMinutes,
      plannedMinutes: plannedSession.plannedMinutes,
    )
        ? completedPlanBonus
        : 0;
  }

  static int totalSp(List<Proof> proofs) {
    return proofs.fold(0, (sum, proof) => sum + proof.totalSp);
  }

  static int spToday(List<Proof> proofs) {
    final today = ProofDateUtils.dateOnly(DateTime.now());
    return totalSp(
      proofs
          .where((proof) => ProofDateUtils.isSameDay(proof.date, today))
          .toList(),
    );
  }

  static int spThisWeek(List<Proof> proofs) {
    return totalSp(StatsUtils.proofsFromLastSevenDays(proofs));
  }

  static int spThisMonth(List<Proof> proofs) {
    final now = DateTime.now();
    return totalSp(
      proofs
          .where(
            (proof) =>
                proof.date.year == now.year && proof.date.month == now.month,
          )
          .toList(),
    );
  }

  static int spForDay(List<Proof> proofs, DateTime day) {
    return totalSp(
      proofs
          .where((proof) => ProofDateUtils.isSameDay(proof.date, day))
          .toList(),
    );
  }

  static Map<String, int> spBySkill(List<Proof> proofs) {
    final totals = <String, int>{};

    for (final proof in proofs) {
      totals.update(
        proof.skillId,
        (value) => value + proof.totalSp,
        ifAbsent: () => proof.totalSp,
      );
    }

    return totals;
  }

  static String bestSkillBySp(List<Proof> proofs, List<Skill> skills) {
    final totals = spBySkill(proofs);
    if (totals.isEmpty) {
      return 'None yet';
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final skillId = sorted.first.key;

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

  static int completedPlannedCount(List<PlannedSession> sessions) {
    return sessions
        .where((session) => session.status == PlannedSessionStatus.completed)
        .length;
  }

  static int missedPlannedCount(List<PlannedSession> sessions) {
    return sessions
        .where((session) => session.status == PlannedSessionStatus.missed)
        .length;
  }

  static double completionRate(List<PlannedSession> sessions) {
    final counted = sessions
        .where(
          (session) =>
              session.status == PlannedSessionStatus.completed ||
              session.status == PlannedSessionStatus.partiallyCompleted ||
              session.status == PlannedSessionStatus.missed,
        )
        .toList();
    if (counted.isEmpty) {
      return 0;
    }

    return completedPlannedCount(counted) / counted.length;
  }
}
