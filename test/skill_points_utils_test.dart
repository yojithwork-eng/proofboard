import 'package:flutter_test/flutter_test.dart';
import 'package:proofboard/models/app_mode.dart';
import 'package:proofboard/models/planned_session.dart';
import 'package:proofboard/models/proof.dart';
import 'package:proofboard/models/skill.dart';
import 'package:proofboard/utils/skill_points_utils.dart';

void main() {
  test('old duration-only proof JSON earns normal time-based SP', () {
    final proof = Proof.fromJson({
      'id': 'old-proof',
      'title': 'Old study proof',
      'skillId': 'skill_studying',
      'minutes': 45,
      'note': 'Legacy proof',
      'createdAt': '2026-07-10T12:00:00.000',
    });

    expect(proof.startTime, isNull);
    expect(proof.endTime, isNull);
    expect(proof.baseSp, 3);
    expect(proof.bonusSp, 0);
    expect(proof.totalSp, 3);
  });

  test('planned completion earns base SP and bonus SP at 80 percent', () {
    final plan = PlannedSession(
      id: 'plan-1',
      skillId: starterSkills.first.id,
      title: 'Coding block',
      note: '',
      date: DateTime(2026, 7, 10),
      plannedStartTime: '09:00',
      plannedEndTime: '10:30',
      plannedMinutes: 90,
      mode: AppMode.productivity,
      status: PlannedSessionStatus.planned,
      createdAt: DateTime(2026, 7, 9),
    );

    final baseSp = SkillPointsUtils.baseSpForMinutes(90);
    final bonusSp = SkillPointsUtils.bonusForProof(
      completedMinutes: 90,
      plannedSession: plan,
    );

    expect(baseSp, 6);
    expect(bonusSp, 5);
    expect(
      SkillPointsUtils.statusForProof(
        completedMinutes: 90,
        plannedSession: plan,
      ),
      PlannedSessionStatus.completed,
    );
  });

  test('partial planned completion earns no plan bonus', () {
    final plan = PlannedSession(
      id: 'plan-2',
      skillId: starterSkills.first.id,
      title: 'Study block',
      note: '',
      date: DateTime(2026, 7, 10),
      plannedStartTime: '09:00',
      plannedEndTime: '10:30',
      plannedMinutes: 90,
      mode: AppMode.productivity,
      status: PlannedSessionStatus.planned,
      createdAt: DateTime(2026, 7, 9),
    );

    expect(SkillPointsUtils.baseSpForMinutes(45), 3);
    expect(
      SkillPointsUtils.bonusForProof(
        completedMinutes: 45,
        plannedSession: plan,
      ),
      0,
    );
    expect(
      SkillPointsUtils.statusForProof(
        completedMinutes: 45,
        plannedSession: plan,
      ),
      PlannedSessionStatus.partiallyCompleted,
    );
  });
}
