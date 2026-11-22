import 'dart:math';
import '../../../data/models/student_profile.dart';
import '../../../data/models/team.dart';
import '../../../data/models/team_role.dart';
import '../../../data/models/match_breakdown.dart';

class MatchingEngine {
  /// Deterministic Smart Match Calculation strictly following VisioSpark SRS.
  /// S = (0.40 * Skills) + (0.25 * Interests) + (0.20 * ProjectType) + (0.15 * AvailabilitySemester)
  static MatchBreakdown calculateMatch({
    required StudentProfile candidate,
    required StudentProfile currentUser,
    required Team? currentTeam,
  }) {
    final List<String> reasons = [];
    final List<String> matchingSkills = [];

    // 1. SKILLS SCORE (40%)
    double skillsScore = 0.0;
    final Set<String> candidateSkillsLower = candidate.skills
        .map((s) => s.trim().toLowerCase())
        .toSet();

    // Check open team roles
    final List<TeamRole> openRoles =
        currentTeam?.roles.where((r) => r.isOpen).toList() ?? [];

    final Set<String> requiredRoleSkills = {};
    for (final role in openRoles) {
      for (final skill in role.requiredSkills) {
        requiredRoleSkills.add(skill.trim());
      }
    }

    if (requiredRoleSkills.isNotEmpty) {
      // Open roles exist -> match against open role requirements
      int matchedCount = 0;
      for (final reqSkill in requiredRoleSkills) {
        if (candidateSkillsLower.contains(reqSkill.toLowerCase())) {
          matchedCount++;
          matchingSkills.add(reqSkill);
        }
      }
      skillsScore = (matchedCount / requiredRoleSkills.length) * 100.0;

      // Identify which specific open role the candidate helps fill
      for (final role in openRoles) {
        final matchesThisRole = role.requiredSkills.any(
          (s) => candidateSkillsLower.contains(s.trim().toLowerCase()),
        );
        if (matchesThisRole) {
          reasons.add('Helps fill open role: ${role.title}');
        }
      }
    } else {
      // Fallback: match complementary/shared skills between currentUser and candidate
      final Set<String> allTargetSkills = {...currentUser.skills};
      if (allTargetSkills.isEmpty) {
        skillsScore = candidate.skills.isNotEmpty ? 50.0 : 0.0;
      } else {
        int matchedCount = 0;
        for (final userSkill in currentUser.skills) {
          if (candidateSkillsLower.contains(userSkill.toLowerCase())) {
            matchedCount++;
            matchingSkills.add(userSkill);
          }
        }
        skillsScore = (matchedCount / allTargetSkills.length) * 100.0;
        // Cap at 100
        skillsScore = min(100.0, skillsScore);
      }
    }
    skillsScore = skillsScore.clamp(0.0, 100.0);

    // Add shared skill reasons
    for (final skill in matchingSkills.take(2)) {
      if (!reasons.any((r) => r.contains(skill))) {
        reasons.add('Shares skill: $skill');
      }
    }

    // 2. INTERESTS SCORE (25%) - Jaccard Similarity Index
    double interestsScore = 0.0;
    final Set<String> candidateInterestsLower = candidate.interests
        .map((i) => i.trim().toLowerCase())
        .toSet();
    final Set<String> userInterestsLower = currentUser.interests
        .map((i) => i.trim().toLowerCase())
        .toSet();

    if (candidateInterestsLower.isNotEmpty || userInterestsLower.isNotEmpty) {
      final intersection = candidateInterestsLower.intersection(
        userInterestsLower,
      );
      final union = candidateInterestsLower.union(userInterestsLower);
      if (union.isNotEmpty) {
        final jaccard = intersection.length / union.length;
        interestsScore = (jaccard * 100.0).clamp(0.0, 100.0);

        // Add matching interest reasons
        for (final interest in candidate.interests) {
          if (userInterestsLower.contains(interest.trim().toLowerCase())) {
            reasons.add('Shared interest: $interest');
          }
        }
      }
    }

    // 3. PROJECT TYPE SCORE (20%)
    double projectTypeScore = 0.0;
    final teamOrUserProjectType =
        currentTeam != null && currentTeam.projectType.isNotEmpty
        ? currentTeam.projectType
        : currentUser.projectType;

    final candidateType = candidate.projectType.trim();
    final targetType = teamOrUserProjectType.trim();

    if (candidateType == 'Both' ||
        targetType == 'Both' ||
        candidateType == targetType) {
      projectTypeScore = 100.0;
      if (candidateType == targetType && candidateType != 'Both') {
        reasons.add('Both target $candidateType');
      } else {
        reasons.add('Compatible project scope');
      }
    } else {
      projectTypeScore = 0.0;
    }

    // 4. AVAILABILITY & SEMESTER SCORE (15%)
    // 4a. Availability Compatibility (50% of this subscore)
    double availabilityScore = 0.0;
    final candidateAvail = candidate.availability.toLowerCase();
    final userAvail = currentUser.availability.toLowerCase();

    if (candidateAvail == userAvail) {
      availabilityScore = 100.0;
      reasons.add('Matching availability');
    } else if (candidateAvail.contains('flexible') ||
        userAvail.contains('flexible')) {
      availabilityScore = 85.0;
      reasons.add('Flexible schedule compatibility');
    } else if ((candidateAvail.contains('weekend') &&
            userAvail.contains('weekend')) ||
        (candidateAvail.contains('part-time') &&
            userAvail.contains('part-time'))) {
      availabilityScore = 65.0;
      reasons.add('Compatible working hours');
    } else {
      availabilityScore = 30.0;
    }

    // 4b. Semester Proximity (50% of this subscore)
    final diff = (candidate.semester - currentUser.semester).abs();
    double semesterScore = 0.0;
    if (diff == 0) {
      semesterScore = 100.0;
      reasons.add('Same semester (Sem ${candidate.semester})');
    } else if (diff == 1) {
      semesterScore = 80.0;
      reasons.add('Near semester (Diff: 1 sem)');
    } else if (diff == 2) {
      semesterScore = 60.0;
    } else if (diff == 3) {
      semesterScore = 40.0;
    } else {
      semesterScore = 20.0;
    }

    final double availabilitySemesterScore =
        ((availabilityScore * 0.5) + (semesterScore * 0.5)).clamp(0.0, 100.0);

    // FINAL WEIGHTED FORMULA
    // S = (0.40 * Skills) + (0.25 * Interests) + (0.20 * ProjectType) + (0.15 * AvailabilitySemester)
    final double rawFinal =
        (0.40 * skillsScore) +
        (0.25 * interestsScore) +
        (0.20 * projectTypeScore) +
        (0.15 * availabilitySemesterScore);

    final int finalScore = rawFinal.round().clamp(0, 100);

    // Check Skill Gap Analysis
    final List<String> missingSkills = [];
    bool bridgesSkillGap = false;

    if (currentTeam != null && currentTeam.roles.isNotEmpty) {
      final Set<String> allRequired = {};
      for (final r in currentTeam.roles) {
        allRequired.addAll(r.requiredSkills);
      }

      final Set<String> currentTeamSkills = {};
      // Add user skills
      currentTeamSkills.addAll(currentUser.skills.map((s) => s.toLowerCase()));

      for (final req in allRequired) {
        if (!currentTeamSkills.contains(req.toLowerCase())) {
          missingSkills.add(req);
        }
      }

      // Check if candidate possesses any of the missing skills
      final candidateHasMissing = missingSkills.any(
        (m) => candidateSkillsLower.contains(m.toLowerCase()),
      );
      if (candidateHasMissing) {
        bridgesSkillGap = true;
        reasons.insert(0, 'Bridges critical team skill gap');
      }
    }

    // Match label
    String label;
    if (finalScore >= 80) {
      label = 'Excellent Match';
    } else if (finalScore >= 65) {
      label = 'Strong Match';
    } else if (finalScore >= 45) {
      label = 'Good Match';
    } else {
      label = 'Potential Match';
    }

    if (reasons.isEmpty) {
      reasons.add('Potential peer collaborator');
    }

    return MatchBreakdown(
      candidateId: candidate.id,
      skillsScore: skillsScore,
      interestsScore: interestsScore,
      projectTypeScore: projectTypeScore,
      availabilitySemesterScore: availabilitySemesterScore,
      finalScore: finalScore,
      matchReasons: reasons.toSet().toList(), // deduplicate
      matchingSkills: matchingSkills,
      missingSkills: missingSkills,
      bridgesSkillGap: bridgesSkillGap,
      label: label,
    );
  }
}
