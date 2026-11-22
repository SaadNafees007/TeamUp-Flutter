import 'dart:convert';
import 'team_role.dart';

class Team {
  final String id;
  final String title;
  final String description;
  final String projectType;
  final String leaderId;
  final List<TeamRole> roles;
  final List<String> memberIds;
  final Map<String, String> memberRoleMap; // studentId -> roleId
  final DateTime createdAt;

  Team({
    required this.id,
    required this.title,
    required this.description,
    required this.projectType,
    required this.leaderId,
    required this.roles,
    required this.memberIds,
    required this.memberRoleMap,
    required this.createdAt,
  });

  int get openRolesCount => roles.where((r) => r.isOpen).length;
  int get totalRolesCount => roles.length;
  int get totalMembersCount => memberIds.length;

  Team copyWith({
    String? id,
    String? title,
    String? description,
    String? projectType,
    String? leaderId,
    List<TeamRole>? roles,
    List<String>? memberIds,
    Map<String, String>? memberRoleMap,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      leaderId: leaderId ?? this.leaderId,
      roles: roles ?? this.roles,
      memberIds: memberIds ?? this.memberIds,
      memberRoleMap: memberRoleMap ?? this.memberRoleMap,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectType': projectType,
      'leaderId': leaderId,
      'roles': roles.map((r) => r.toMap()).toList(),
      'memberIds': memberIds,
      'memberRoleMap': memberRoleMap,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      projectType: map['projectType'] as String? ?? 'Final Year Project',
      leaderId: map['leaderId'] as String? ?? '',
      roles:
          (map['roles'] as List<dynamic>?)
              ?.map((r) => TeamRole.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      memberRoleMap: Map<String, String>.from(map['memberRoleMap'] ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Team.fromJson(String source) =>
      Team.fromMap(json.decode(source) as Map<String, dynamic>);
}
