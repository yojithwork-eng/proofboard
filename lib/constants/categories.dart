import 'package:flutter/material.dart';

import '../models/proof.dart';

const proofCategories = ProofCategory.values;

Color categoryColor(ProofCategory category) {
  return switch (category) {
    ProofCategory.coding => const Color(0xFF3157D5),
    ProofCategory.cad => const Color(0xFF7C3AED),
    ProofCategory.robotics => const Color(0xFF00897B),
    ProofCategory.gym => const Color(0xFFE65100),
    ProofCategory.studying => const Color(0xFF1565C0),
    ProofCategory.networking => const Color(0xFFC2185B),
    ProofCategory.reading => const Color(0xFF2E7D32),
    ProofCategory.other => const Color(0xFF546E7A),
  };
}

IconData categoryIcon(ProofCategory category) {
  return switch (category) {
    ProofCategory.coding => Icons.code,
    ProofCategory.cad => Icons.architecture,
    ProofCategory.robotics => Icons.precision_manufacturing,
    ProofCategory.gym => Icons.fitness_center,
    ProofCategory.studying => Icons.school,
    ProofCategory.networking => Icons.groups,
    ProofCategory.reading => Icons.menu_book,
    ProofCategory.other => Icons.auto_awesome,
  };
}
