import 'dart:convert';

class FilterPreset {
  final String id;
  final String name;
  final String? department;
  final int? minSemester;
  final int? maxSemester;
  final List<String> skills;
  final String? projectType;

  FilterPreset({
    required this.id,
    required this.name,
    this.department,
    this.minSemester,
    this.maxSemester,
    this.skills = const [],
    this.projectType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'minSemester': minSemester,
      'maxSemester': maxSemester,
      'skills': skills,
      'projectType': projectType,
    };
  }

  factory FilterPreset.fromMap(Map<String, dynamic> map) {
    return FilterPreset(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      department: map['department'] as String?,
      minSemester: (map['minSemester'] as num?)?.toInt(),
      maxSemester: (map['maxSemester'] as num?)?.toInt(),
      skills: List<String>.from(map['skills'] ?? []),
      projectType: map['projectType'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory FilterPreset.fromJson(String source) =>
      FilterPreset.fromMap(json.decode(source) as Map<String, dynamic>);
}
