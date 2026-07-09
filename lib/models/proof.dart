enum ProofCategory {
  coding,
  cad,
  robotics,
  gym,
  studying,
  networking,
  reading,
  other,
}

extension ProofCategoryDisplay on ProofCategory {
  String get displayName {
    return switch (this) {
      ProofCategory.coding => 'Coding',
      ProofCategory.cad => 'CAD',
      ProofCategory.robotics => 'Robotics',
      ProofCategory.gym => 'Gym',
      ProofCategory.studying => 'Studying',
      ProofCategory.networking => 'Networking',
      ProofCategory.reading => 'Reading',
      ProofCategory.other => 'Other',
    };
  }

  static ProofCategory fromName(String? name) {
    return ProofCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => ProofCategory.other,
    );
  }
}

class Proof {
  const Proof({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String title;
  final ProofCategory category;
  final int minutes;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'minutes': minutes,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Proof.fromJson(Map<String, dynamic> json) {
    return Proof(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled proof',
      category: ProofCategoryDisplay.fromName(json['category'] as String?),
      minutes: json['minutes'] is int ? json['minutes'] as int : 0,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
