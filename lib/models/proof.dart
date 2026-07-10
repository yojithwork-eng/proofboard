import 'skill.dart';

class Proof {
  const Proof({
    required this.id,
    required this.title,
    required this.skillId,
    required this.minutes,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String skillId;
  final int minutes;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'skillId': skillId,
      'minutes': minutes,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Proof.fromJson(Map<String, dynamic> json) {
    final savedSkillId = json['skillId'] as String?;
    final legacyCategory = json['category'] as String?;

    return Proof(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled proof',
      skillId: savedSkillId?.isNotEmpty == true
          ? savedSkillId!
          : Skill.idForLegacyCategory(legacyCategory),
      minutes: json['minutes'] is int ? json['minutes'] as int : 0,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
