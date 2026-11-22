class MatchBreakdown {
  final String candidateId;
  final double skillsScore; // 0 to 100
  final double interestsScore; // 0 to 100
  final double projectTypeScore; // 0 to 100
  final double availabilitySemesterScore; // 0 to 100
  final int finalScore; // 0 to 100
  final List<String> matchReasons;
  final List<String> matchingSkills;
  final List<String> missingSkills;
  final bool bridgesSkillGap;
  final String
  label; // "Excellent Match", "Strong Match", "Good Match", "Potential Match"

  MatchBreakdown({
    required this.candidateId,
    required this.skillsScore,
    required this.interestsScore,
    required this.projectTypeScore,
    required this.availabilitySemesterScore,
    required this.finalScore,
    required this.matchReasons,
    required this.matchingSkills,
    required this.missingSkills,
    this.bridgesSkillGap = false,
    required this.label,
  });

  // Weighted contribution getters
  double get skillsWeighted => (skillsScore * 0.40);
  double get interestsWeighted => (interestsScore * 0.25);
  double get projectTypeWeighted => (projectTypeScore * 0.20);
  double get availabilitySemesterWeighted => (availabilitySemesterScore * 0.15);
}
