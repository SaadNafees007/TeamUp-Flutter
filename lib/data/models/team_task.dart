import 'dart:convert';

class TeamTask {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final String? assignedMemberId;

  TeamTask({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.assignedMemberId,
  });

  TeamTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    String? assignedMemberId,
  }) {
    return TeamTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'assignedMemberId': assignedMemberId,
    };
  }

  factory TeamTask.fromMap(Map<String, dynamic> map) {
    return TeamTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      assignedMemberId: map['assignedMemberId'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory TeamTask.fromJson(String source) =>
      TeamTask.fromMap(json.decode(source) as Map<String, dynamic>);
}
