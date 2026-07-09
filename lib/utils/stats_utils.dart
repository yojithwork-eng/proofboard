import '../constants/categories.dart';
import '../models/proof.dart';
import 'date_utils.dart';

class StatsUtils {
  static int totalMinutes(List<Proof> proofs) {
    return proofs.fold(0, (sum, proof) => sum + proof.minutes);
  }

  static Map<ProofCategory, int> categoryCounts(List<Proof> proofs) {
    final counts = <ProofCategory, int>{};

    for (final proof in proofs) {
      counts.update(proof.category, (count) => count + 1, ifAbsent: () => 1);
    }

    return counts;
  }

  static int activeCategoryCount(List<Proof> proofs) {
    return categoryCounts(proofs).length;
  }

  static int currentStreak(List<Proof> proofs) {
    if (proofs.isEmpty) {
      return 0;
    }

    final proofDays = proofs
        .map((proof) => ProofDateUtils.dateOnly(proof.createdAt))
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

  static String bestCategoryName(List<Proof> proofs) {
    final best = bestCategory(proofs);
    return best?.displayName ?? 'None yet';
  }

  static ProofCategory? bestCategory(List<Proof> proofs) {
    final counts = categoryCounts(proofs);
    if (counts.isEmpty) {
      return null;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  static List<Proof> proofsFromLastSevenDays(List<Proof> proofs) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return proofs.where((proof) => proof.createdAt.isAfter(start)).toList();
  }

  static String weeklyRecap(List<Proof> proofs) {
    final weeklyProofs = proofsFromLastSevenDays(proofs);
    if (weeklyProofs.isEmpty) {
      return 'No proofs logged this week yet. Add one small proof today and start building momentum.';
    }

    final categories = _categoryNamesFor(weeklyProofs);
    final strongest = bestCategoryName(weeklyProofs);
    final minutes = totalMinutes(weeklyProofs);

    return 'This week you logged ${weeklyProofs.length} proofs across $categories for a total of $minutes minutes. Your strongest category was $strongest. Keep building proof one day at a time.';
  }

  static String shareRecap(List<Proof> proofs) {
    final weeklyProofs = proofsFromLastSevenDays(proofs);
    if (weeklyProofs.isEmpty) {
      return 'This week on ProofBoard, I am starting my proof-of-work habit. Small steps, real proof.';
    }

    final categories = _categoryNamesFor(weeklyProofs);
    final minutes = totalMinutes(weeklyProofs);

    return 'This week on ProofBoard, I logged ${weeklyProofs.length} proofs of work across $categories. Total focused time: $minutes minutes. Small steps, real proof.';
  }

  static String _categoryNamesFor(List<Proof> proofs) {
    final counts = categoryCounts(proofs);
    final names = proofCategories
        .where((category) => counts.containsKey(category))
        .map((category) => category.displayName)
        .toList();

    if (names.isEmpty) {
      return 'no categories yet';
    }

    if (names.length == 1) {
      return names.first;
    }

    if (names.length == 2) {
      return '${names.first} and ${names.last}';
    }

    return '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}';
  }
}
