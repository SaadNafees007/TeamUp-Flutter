import 'dart:convert';

class StudentProfile {
  final String id;
  final String name;
  final String department;
  final int semester;
  final List<String> skills;
  final List<String> interests;
  final String projectType; // "Semester Project", "Final Year Project", "Both"
  final String availability;
  final String bio;
  final String avatar; // "avatar_1" .. "avatar_6" or custom file path
  final bool isCurrentUser;

  StudentProfile({
    required this.id,
    required this.name,
    required this.department,
    required this.semester,
    required this.skills,
    required this.interests,
    required this.projectType,
    required this.availability,
    required this.bio,
    this.avatar = 'avatar_1',
    this.isCurrentUser = false,
  });

  StudentProfile copyWith({
    String? id,
    String? name,
    String? department,
    int? semester,
    List<String>? skills,
    List<String>? interests,
    String? projectType,
    String? availability,
    String? bio,
    String? avatar,
    bool? isCurrentUser,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      projectType: projectType ?? this.projectType,
      availability: availability ?? this.availability,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'semester': semester,
      'skills': skills,
      'interests': interests,
      'projectType': projectType,
      'availability': availability,
      'bio': bio,
      'avatar': avatar,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      department: map['department'] as String? ?? '',
      semester: (map['semester'] as num?)?.toInt() ?? 1,
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      projectType: map['projectType'] as String? ?? 'Semester Project',
      availability: map['availability'] as String? ?? 'Flexible',
      bio: map['bio'] as String? ?? '',
      avatar: map['avatar'] as String? ?? 'avatar_1',
      isCurrentUser: map['isCurrentUser'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentProfile.fromJson(String source) =>
      StudentProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
