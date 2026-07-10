import 'package:flutter/foundation.dart';

import '../models/planned_session.dart';
import '../models/proof.dart';
import '../services/planned_session_storage_service.dart';
import '../utils/date_utils.dart';
import '../utils/skill_points_utils.dart';

class PlannedSessionController extends ChangeNotifier {
  PlannedSessionController(this._storageService);

  final PlannedSessionStorageService _storageService;

  List<PlannedSession> _sessions = [];
  bool _isLoading = false;

  List<PlannedSession> get sessions {
    final sorted = List<PlannedSession>.from(_sessions);
    sorted.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return a.plannedStartTime.compareTo(b.plannedStartTime);
    });
    return sorted;
  }

  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    _sessions = await _storageService.loadSessions();
    await refreshMissedSessions(notify: false);

    _isLoading = false;
    notifyListeners();
  }

  PlannedSession? sessionById(String? id) {
    if (id == null) {
      return null;
    }

    for (final session in _sessions) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  List<PlannedSession> sessionsForDay(DateTime day) {
    return sessions
        .where((session) => ProofDateUtils.isSameDay(session.date, day))
        .toList();
  }

  List<PlannedSession> sessionsForMonth(DateTime month) {
    return sessions
        .where(
          (session) =>
              session.date.year == month.year &&
              session.date.month == month.month,
        )
        .toList();
  }

  Future<void> addSession(PlannedSession session) async {
    _sessions = [..._sessions, session];
    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  Future<void> updateSession(PlannedSession updatedSession) async {
    _sessions = _sessions
        .map(
          (session) =>
              session.id == updatedSession.id ? updatedSession : session,
        )
        .toList();
    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  Future<PlannedSession?> deleteSession(String id) async {
    final deleted = sessionById(id);
    _sessions = _sessions.where((session) => session.id != id).toList();
    await _storageService.saveSessions(_sessions);
    notifyListeners();
    return deleted;
  }

  Future<void> clearSessions() async {
    _sessions = [];
    await _storageService.clearSessions();
    notifyListeners();
  }

  Future<void> markFromProof(Proof proof) async {
    final plannedSession = sessionById(proof.plannedSessionId);
    if (plannedSession == null) {
      return;
    }

    final status = SkillPointsUtils.statusForProof(
      completedMinutes: proof.minutes,
      plannedSession: plannedSession,
    );
    final updatedSession = plannedSession.copyWith(
      status: status,
      completedProofId: proof.id,
    );

    await updateSession(updatedSession);
  }

  Future<void> unlinkProof(String proofId) async {
    var changed = false;
    _sessions = _sessions.map((session) {
      if (session.completedProofId != proofId) {
        return session;
      }

      changed = true;
      return session.copyWith(
        status: _statusForUnlinkedSession(session),
        completedProofId: null,
      );
    }).toList();

    if (!changed) {
      return;
    }

    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  Future<void> refreshMissedSessions({bool notify = true}) async {
    final today = ProofDateUtils.dateOnly(DateTime.now());
    var changed = false;

    _sessions = _sessions.map((session) {
      final isPast = session.date.isBefore(today);
      final hasNoProof = session.completedProofId == null;
      final canBecomeMissed =
          session.status == PlannedSessionStatus.planned && hasNoProof;

      if (isPast && canBecomeMissed) {
        changed = true;
        return session.copyWith(status: PlannedSessionStatus.missed);
      }

      return session;
    }).toList();

    if (!changed) {
      return;
    }

    await _storageService.saveSessions(_sessions);
    if (notify) {
      notifyListeners();
    }
  }

  PlannedSessionStatus _statusForUnlinkedSession(PlannedSession session) {
    final today = ProofDateUtils.dateOnly(DateTime.now());
    if (session.date.isBefore(today)) {
      return PlannedSessionStatus.missed;
    }
    return PlannedSessionStatus.planned;
  }
}
