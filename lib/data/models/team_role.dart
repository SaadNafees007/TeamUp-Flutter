import 'dart:convert';

class TeamRole {
  final String id;
  final String title;
  final List<String> requiredSkills;
  final String? assignedMemberId;

  TeamRole({
    required this.id,
    required this.title,
    required this.requiredSkills,
    this.assignedMemberId,
  });

  bool get isOpen => assignedMemberId == null || assignedMemberId!.isEmpty;

  TeamRole copyWith({
    String? id,
    String? title,
    List<String>? requiredSkills,
    String? assignedMemberId,
    bool clearAssigned = false,
  }) {
    return TeamRole(
      id: id ?? this.id,
      title: title ?? this.title,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      assignedMemberId: clearAssigned
          ? null
          : (assignedMemberId ?? this.assignedMemberId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'requiredSkills': requiredSkills,
      'assignedMemberId': assignedMemberId,
    };
  }

  factory TeamRole.fromMap(Map<String, dynamic> map) {
    return TeamRole(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      assignedMemberId: map['assignedMemberId'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory TeamRole.fromJson(String source) =>
      TeamRole.fromMap(json.decode(source) as Map<String, dynamic>);
}
