import '../models/app_mode.dart';
import '../models/export_format.dart';
import '../models/proof.dart';
import '../models/skill.dart';
import 'stats_utils.dart';

class ExportUtils {
  static String generate({
    required ExportFormat format,
    required List<Proof> proofs,
    required List<Skill> skills,
    required AppMode mode,
  }) {
    final totalProofs = proofs.length;
    final totalMinutes = StatsUtils.totalMinutes(proofs);
    final currentStreak = StatsUtils.currentStreak(proofs);
    final strongestSkill = StatsUtils.bestSkillName(proofs, skills);
    final practicedSkills = _skillNamesFor(proofs, skills);
    final weeklyProofs = StatsUtils.proofsFromLastSevenDays(proofs);
    final weeklyProofCount = weeklyProofs.length;
    final weeklyMinutes = StatsUtils.totalMinutes(weeklyProofs);
    final weeklySkills = _skillNamesFor(weeklyProofs, skills);

    return switch (format) {
      ExportFormat.resumeBullet => _resumeBullet(
          totalProofs: totalProofs,
          totalMinutes: totalMinutes,
          currentStreak: currentStreak,
          strongestSkill: strongestSkill,
          practicedSkills: practicedSkills,
          mode: mode,
        ),
      ExportFormat.linkedInPost => _linkedInPost(
          totalProofs: totalProofs,
          totalMinutes: totalMinutes,
          currentStreak: currentStreak,
          strongestSkill: strongestSkill,
          practicedSkills: practicedSkills,
          weeklyProofCount: weeklyProofCount,
          weeklyMinutes: weeklyMinutes,
          weeklySkills: weeklySkills,
          mode: mode,
        ),
      ExportFormat.twitterPost => _twitterPost(
          totalProofs: totalProofs,
          totalMinutes: totalMinutes,
          currentStreak: currentStreak,
          strongestSkill: strongestSkill,
          weeklyProofCount: weeklyProofCount,
          weeklyMinutes: weeklyMinutes,
          mode: mode,
        ),
      ExportFormat.instagramCaption => _instagramCaption(
          totalProofs: totalProofs,
          totalMinutes: totalMinutes,
          currentStreak: currentStreak,
          strongestSkill: strongestSkill,
          practicedSkills: practicedSkills,
          weeklyProofCount: weeklyProofCount,
          weeklyMinutes: weeklyMinutes,
          weeklySkills: weeklySkills,
          mode: mode,
        ),
      ExportFormat.portfolioSummary => _portfolioSummary(
          totalProofs: totalProofs,
          totalMinutes: totalMinutes,
          currentStreak: currentStreak,
          strongestSkill: strongestSkill,
          practicedSkills: practicedSkills,
          mode: mode,
        ),
      ExportFormat.weeklyRecap => StatsUtils.weeklyRecap(proofs, skills),
    };
  }

  static String _resumeBullet({
    required int totalProofs,
    required int totalMinutes,
    required int currentStreak,
    required String strongestSkill,
    required String practicedSkills,
    required AppMode mode,
  }) {
    return '- Logged $totalProofs proof-of-work entries across $practicedSkills, totaling $totalMinutes focused minutes in ${mode.displayName} Mode, with a $currentStreak-day current streak and strongest progress in $strongestSkill.';
  }

  static String _linkedInPost({
    required int totalProofs,
    required int totalMinutes,
    required int currentStreak,
    required String strongestSkill,
    required String practicedSkills,
    required int weeklyProofCount,
    required int weeklyMinutes,
    required String weeklySkills,
    required AppMode mode,
  }) {
    return 'ProofBoard update: I have logged $totalProofs proofs of work across $practicedSkills for a total of $totalMinutes focused minutes.\n\nThis week: $weeklyProofCount proofs, $weeklyMinutes minutes, across $weeklySkills.\n\nCurrent streak: $currentStreak days. Strongest skill so far: $strongestSkill.\n\nI am using ${mode.displayName} Mode to keep small daily work visible. Small steps, real proof.';
  }

  static String _twitterPost({
    required int totalProofs,
    required int totalMinutes,
    required int currentStreak,
    required String strongestSkill,
    required int weeklyProofCount,
    required int weeklyMinutes,
    required AppMode mode,
  }) {
    return 'ProofBoard check-in: $totalProofs proofs logged, $totalMinutes focused minutes, $currentStreak-day streak.\n\nThis week: $weeklyProofCount proofs / $weeklyMinutes min.\n\nMode: ${mode.displayName}. Strongest skill: $strongestSkill.\n\nSmall steps, real proof. #BuildInPublic';
  }

  static String _instagramCaption({
    required int totalProofs,
    required int totalMinutes,
    required int currentStreak,
    required String strongestSkill,
    required String practicedSkills,
    required int weeklyProofCount,
    required int weeklyMinutes,
    required String weeklySkills,
    required AppMode mode,
  }) {
    return 'Proof stack update:\n\n$totalProofs proofs logged\n$totalMinutes focused minutes\n$currentStreak-day streak\nStrongest skill: $strongestSkill\n\nThis week I added $weeklyProofCount proofs across $weeklySkills for $weeklyMinutes minutes.\n\nMode: ${mode.displayName}\nSkills practiced: $practicedSkills\n\nSmall work today. Real portfolio tomorrow.\n\n#ProofOfWork #StudentBuilder #Progress';
  }

  static String _portfolioSummary({
    required int totalProofs,
    required int totalMinutes,
    required int currentStreak,
    required String strongestSkill,
    required String practicedSkills,
    required AppMode mode,
  }) {
    return 'My ProofBoard tracks small, consistent proof-of-work entries across $practicedSkills. So far, I have logged $totalProofs proofs and $totalMinutes focused minutes, with a current streak of $currentStreak days. My strongest skill area is $strongestSkill. I am currently using ${mode.displayName} Mode to organize my progress and turn daily effort into a visible portfolio.';
  }

  static String _skillNamesFor(List<Proof> proofs, List<Skill> skills) {
    final counts = StatsUtils.skillCounts(proofs);
    final names = counts.keys
        .map((skillId) => _skillNameFor(skillId, skills))
        .toSet()
        .toList()
      ..sort();

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
