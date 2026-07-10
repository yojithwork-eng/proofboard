import '../utils/date_utils.dart';
import 'app_mode.dart';

enum PlannedSessionStatus {
  planned,
  completed,
  missed,
  partiallyCompleted,
}

extension PlannedSessionStatusDisplay on PlannedSessionStatus {
  String get displayName {
    return switch (this) {
      PlannedSessionStatus.planned => 'Planned',
      PlannedSessionStatus.completed => 'Completed',
      PlannedSessionStatus.missed => 'Missed',
      PlannedSessionStatus.partiallyCompleted => 'Partial',
    };
  }

  static PlannedSessionStatus fromName(String? name) {
    return PlannedSessionStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => PlannedSessionStatus.planned,
    );
  }
}

class PlannedSession {
  PlannedSession({
    required this.id,
    required this.skillId,
    required this.title,
    required this.note,
    required DateTime date,
    required this.plannedStartTime,
    required this.plannedEndTime,
    required this.plannedMinutes,
    required this.mode,
    required this.status,
    required this.createdAt,
    this.completedProofId,
  }) : date = ProofDateUtils.dateOnly(date);

  final String id;
  final String skillId;
  final String title;
  final String note;
  final DateTime date;
  final String plannedStartTime;
  final String plannedEndTime;
  final int plannedMinutes;
  final AppMode mode;
  final PlannedSessionStatus status;
  final DateTime createdAt;
  final String? completedProofId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'title': title,
      'note': note,
      'date': ProofDateUtils.dateKey(date),
      'plannedStartTime': plannedStartTime,
      'plannedEndTime': plannedEndTime,
      'plannedMinutes': plannedMinutes,
      'mode': mode.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedProofId': completedProofId,
    };
  }

  factory PlannedSession.fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    final date = ProofDateUtils.tryParseDate(json['date'] as String?) ??
        ProofDateUtils.dateOnly(createdAt);
    final startTime = _stringOrDefault(json['plannedStartTime'], '09:00');
    final endTime = _stringOrDefault(json['plannedEndTime'], '10:00');
    final derivedMinutes = ProofDateUtils.minutesBetween(startTime, endTime);

    return PlannedSession(
      id: json['id'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      title: json['title'] as String? ?? 'Planned session',
      note: json['note'] as String? ?? '',
      date: date,
      plannedStartTime: startTime,
      plannedEndTime: endTime,
      plannedMinutes: json['plannedMinutes'] is int
          ? json['plannedMinutes'] as int
          : derivedMinutes,
      mode: AppModeDisplay.fromName(json['mode'] as String?),
      status: PlannedSessionStatusDisplay.fromName(
        json['status'] as String?,
      ),
      createdAt: createdAt,
      completedProofId: _nullableString(json['completedProofId']),
    );
  }

  PlannedSession copyWith({
    String? skillId,
    String? title,
    String? note,
    DateTime? date,
    String? plannedStartTime,
    String? plannedEndTime,
    int? plannedMinutes,
    AppMode? mode,
    PlannedSessionStatus? status,
    DateTime? createdAt,
    Object? completedProofId = _sentinel,
  }) {
    return PlannedSession(
      id: id,
      skillId: skillId ?? this.skillId,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      plannedStartTime: plannedStartTime ?? this.plannedStartTime,
      plannedEndTime: plannedEndTime ?? this.plannedEndTime,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedProofId: completedProofId == _sentinel
          ? this.completedProofId
          : completedProofId as String?,
    );
  }

  static String _stringOrDefault(Object? value, String fallback) {
    if (value is! String || value.trim().isEmpty) {
      return fallback;
    }
    return value;
  }

  static String? _nullableString(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value;
  }
}

const Object _sentinel = Object();
