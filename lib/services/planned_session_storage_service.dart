import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/planned_session.dart';

class PlannedSessionStorageService {
  static const String _plannedSessionsKey = 'proofboard_planned_sessions';

  Future<List<PlannedSession>> loadSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final rawJson = preferences.getString(_plannedSessionsKey);

    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PlannedSession.fromJson)
          .where(
            (session) => session.id.isNotEmpty && session.skillId.isNotEmpty,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<PlannedSession> sessions) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      sessions.map((session) => session.toJson()).toList(),
    );

    await preferences.setString(_plannedSessionsKey, encoded);
  }

  Future<void> clearSessions() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_plannedSessionsKey);
  }
}
