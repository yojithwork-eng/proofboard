import '../utils/date_utils.dart';
import 'app_mode.dart';
import 'skill.dart';

class Proof {
  Proof({
    required this.id,
    required this.title,
    required this.skillId,
    required this.minutes,
    required this.note,
    required this.createdAt,
    DateTime? date,
    this.startTime,
    this.endTime,
    AppMode? mode,
    this.plannedSessionId,
    int? baseSp,
    int? bonusSp,
    this.spRuleVersion = 1,
  })  : date = ProofDateUtils.dateOnly(date ?? createdAt),
        mode = mode ?? AppMode.general,
        baseSp = baseSp ?? (minutes ~/ 15),
        bonusSp = bonusSp ?? 0;

  final String id;
  final String title;
  final String skillId;
  final int minutes;
  final String note;
  final DateTime createdAt;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final AppMode mode;
  final String? plannedSessionId;
  final int baseSp;
  final int bonusSp;
  final int spRuleVersion;

  bool get hasTimeRange => startTime != null && endTime != null;

  int get totalSp => baseSp + bonusSp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'skillId': skillId,
      'minutes': minutes,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'date': ProofDateUtils.dateKey(date),
      'startTime': startTime,
      'endTime': endTime,
      'mode': mode.name,
      'plannedSessionId': plannedSessionId,
      'baseSp': baseSp,
      'bonusSp': bonusSp,
      'spRuleVersion': spRuleVersion,
    };
  }

  factory Proof.fromJson(Map<String, dynamic> json) {
    final savedSkillId = json['skillId'] as String?;
    final legacyCategory = json['category'] as String?;
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    final minutes = json['minutes'] is int ? json['minutes'] as int : 0;

    return Proof(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled proof',
      skillId: savedSkillId?.isNotEmpty == true
          ? savedSkillId!
          : Skill.idForLegacyCategory(legacyCategory),
      minutes: minutes,
      note: json['note'] as String? ?? '',
      createdAt: createdAt,
      date: ProofDateUtils.tryParseDate(json['date'] as String?) ??
          ProofDateUtils.dateOnly(createdAt),
      startTime: _nullableString(json['startTime']),
      endTime: _nullableString(json['endTime']),
      mode: AppModeDisplay.fromName(json['mode'] as String?),
      plannedSessionId: _nullableString(json['plannedSessionId']),
      baseSp: json['baseSp'] is int ? json['baseSp'] as int : minutes ~/ 15,
      bonusSp: json['bonusSp'] is int ? json['bonusSp'] as int : 0,
      spRuleVersion:
          json['spRuleVersion'] is int ? json['spRuleVersion'] as int : 1,
    );
  }

  Proof copyWith({
    String? title,
    String? skillId,
    int? minutes,
    String? note,
    DateTime? createdAt,
    DateTime? date,
    String? startTime,
    String? endTime,
    AppMode? mode,
    Object? plannedSessionId = _sentinel,
    int? baseSp,
    int? bonusSp,
    int? spRuleVersion,
  }) {
    return Proof(
      id: id,
      title: title ?? this.title,
      skillId: skillId ?? this.skillId,
      minutes: minutes ?? this.minutes,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mode: mode ?? this.mode,
      plannedSessionId: plannedSessionId == _sentinel
          ? this.plannedSessionId
          : plannedSessionId as String?,
      baseSp: baseSp ?? this.baseSp,
      bonusSp: bonusSp ?? this.bonusSp,
      spRuleVersion: spRuleVersion ?? this.spRuleVersion,
    );
  }

  static String? _nullableString(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value;
  }
}

const Object _sentinel = Object();
