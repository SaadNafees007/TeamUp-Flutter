import 'package:flutter/material.dart';

class AppColors {
  // Primary SRS Palette
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryIndigoDark = Color(0xFF3730A3);
  static const Color primaryIndigoLight = Color(0xFFEEF2FF);

  static const Color secondarySlate = Color(0xFF64748B);
  static const Color slateLight = Color(0xFFF1F5F9);
  static const Color slateDark = Color(0xFF334155);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  static const Color accentEmerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFFD1FAE5);

  // Semantic Status Colors
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusPendingLight = Color(0xFFFEF3C7);

  static const Color statusAccepted = Color(0xFF10B981); // Green/Emerald
  static const Color statusAcceptedLight = Color(0xFFD1FAE5);

  static const Color statusRejected = Color(0xFFEF4444); // Red
  static const Color statusRejectedLight = Color(0xFFFEE2E2);

  static const Color statusCancelled = Color(0xFF94A3B8); // Grey
  static const Color statusCancelledLight = Color(0xFFF1F5F9);

  static const Color statusInfo = Color(0xFF3B82F6); // Blue
  static const Color statusInfoLight = Color(0xFFDBEAFE);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
}

class AppConstants {
  static const String appName = 'TeamUp';
  static const String competitionName = 'VisioSpark FA26';
  static const String universityName =
      'COMSATS University Islamabad, Wah Campus';

  static const List<String> departments = [
    'Computer Science',
    'Software Engineering',
    'Artificial Intelligence',
    'Cyber Security',
    'Data Science',
    'Electrical Engineering',
  ];

  static const List<String> projectTypes = [
    'Semester Project',
    'Final Year Project',
    'Both',
  ];

  static const List<String> availabilities = [
    'Full-time (20+ hrs/wk)',
    'Part-time (10-20 hrs/wk)',
    'Evenings & Weekends',
    'Weekends Only',
    'Flexible',
  ];

  static const List<String> suggestedSkills = [
    'Flutter',
    'Dart',
    'Java',
    'Python',
    'C++',
    'JavaScript',
    'React',
    'Node.js',
    'Firebase',
    'SQL',
    'UI/UX Design',
    'Machine Learning',
    'AI',
    'Data Science',
    'Web Development',
    'Mobile Development',
    'Backend Development',
    'Cybersecurity',
    'DevOps',
    'IoT',
    'Documentation',
    'Testing',
  ];

  static const List<String> suggestedInterests = [
    'Artificial Intelligence',
    'Mobile Apps',
    'Web Development',
    'Robotics',
    'IoT',
    'Cybersecurity',
    'Data Science',
    'Game Development',
    'Cloud Computing',
    'Software Engineering',
    'UI/UX',
    'Research',
  ];

  static const List<String> presetAvatars = [
    'avatar_1',
    'avatar_2',
    'avatar_3',
    'avatar_4',
    'avatar_5',
    'avatar_6',
  ];
}
