import 'package:flutter/foundation.dart';

import '../models/proof.dart';
import '../services/proof_storage_service.dart';
import '../utils/stats_utils.dart';

class ProofController extends ChangeNotifier {
  ProofController(this._storageService);

  final ProofStorageService _storageService;

  List<Proof> _proofs = [];
  bool _isLoading = false;

  List<Proof> get proofs {
    final sorted = List<Proof>.from(_proofs);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  bool get isLoading => _isLoading;

  int get totalProofs => _proofs.length;

  int get totalMinutes => StatsUtils.totalMinutes(_proofs);

  int get activeCategories => StatsUtils.activeCategoryCount(_proofs);

  int get currentStreak => StatsUtils.currentStreak(_proofs);

  String get bestCategory => StatsUtils.bestCategoryName(_proofs);

  Map<ProofCategory, int> get categoryCounts =>
      StatsUtils.categoryCounts(_proofs);

  Future<void> loadProofs() async {
    _isLoading = true;
    notifyListeners();

    _proofs = await _storageService.loadProofs();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProof(Proof proof) async {
    _proofs = [proof, ..._proofs];
    await _storageService.saveProofs(_proofs);
    notifyListeners();
  }

  Future<void> updateProof(Proof updatedProof) async {
    _proofs = _proofs
        .map((proof) => proof.id == updatedProof.id ? updatedProof : proof)
        .toList();
    await _storageService.saveProofs(_proofs);
    notifyListeners();
  }

  Future<void> deleteProof(String id) async {
    _proofs = _proofs.where((proof) => proof.id != id).toList();
    await _storageService.saveProofs(_proofs);
    notifyListeners();
  }

  Future<void> clearProofs() async {
    _proofs = [];
    await _storageService.clearProofs();
    notifyListeners();
  }

  String weeklyRecap() {
    return StatsUtils.weeklyRecap(_proofs);
  }

  String shareRecap() {
    return StatsUtils.shareRecap(_proofs);
  }
}
