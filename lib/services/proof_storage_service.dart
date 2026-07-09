import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/proof.dart';

class ProofStorageService {
  static const String _proofsKey = 'proofboard_proofs';

  Future<List<Proof>> loadProofs() async {
    final preferences = await SharedPreferences.getInstance();
    final rawJson = preferences.getString(_proofsKey);

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
          .map(Proof.fromJson)
          .where((proof) => proof.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProofs(List<Proof> proofs) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      proofs.map((proof) => proof.toJson()).toList(),
    );

    await preferences.setString(_proofsKey, encoded);
  }

  Future<void> clearProofs() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_proofsKey);
  }
}
