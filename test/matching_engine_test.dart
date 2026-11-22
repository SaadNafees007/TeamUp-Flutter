import 'package:flutter_test/flutter_test.dart';
import 'package:teamup/data/models/student_profile.dart';
import 'package:teamup/data/models/team.dart';
import 'package:teamup/data/models/team_role.dart';
import 'package:teamup/features/matching/services/matching_engine.dart';

void main() {
  group('Smart Match Engine Deterministic Evaluation Tests', () {
    late StudentProfile currentUser;
    late Team currentTeam;

    setUp(() {
      currentUser = StudentProfile(
        id: 'user_1',
        name: 'Zayan Ahmed',
        department: 'Software Engineering',
        semester: 7,
        skills: ['Flutter', 'Dart', 'UI/UX Design'],
        interests: ['Mobile Apps', 'Artificial Intelligence', 'UI/UX'],
        projectType: 'Final Year Project',
        availability: 'Full-time (20+ hrs/wk)',
        bio: 'Leading FYP development.',
      );

      currentTeam = Team(
        id: 'team_1',
        title: 'Smart Campus',
        description: 'AI campus platform',
        projectType: 'Final Year Project',
        leaderId: 'user_1',
        roles: [
          TeamRole(
            id: 'role_flutter',
            title: 'Flutter Developer',
            requiredSkills: ['Flutter', 'Dart'],
            assignedMemberId: 'user_1',
          ),
          TeamRole(
            id: 'role_ai',
            title: 'AI Engineer',
            requiredSkills: ['Python', 'Machine Learning'],
            assignedMemberId: null, // OPEN ROLE
          ),
        ],
        memberIds: ['user_1'],
        memberRoleMap: {'user_1': 'role_flutter'},
        createdAt: DateTime.now(),
      );
    });

    test('Perfect skills match on open role awards 100% skills score', () {
      final candidate = StudentProfile(
        id: 'cand_1',
        name: 'Ayesha Noor',
        department: 'Computer Science',
        semester: 7,
        skills: ['Python', 'Machine Learning'],
        interests: ['Artificial Intelligence'],
        projectType: 'Final Year Project',
        availability: 'Full-time (20+ hrs/wk)',
        bio: 'AI researcher',
      );

      final breakdown = MatchingEngine.calculateMatch(
        candidate: candidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      expect(breakdown.skillsScore, equals(100.0));
      expect(breakdown.skillsWeighted, equals(40.0));
      expect(
        breakdown.matchingSkills,
        containsAll(['Python', 'Machine Learning']),
      );
      expect(
        breakdown.matchReasons.any((r) => r.contains('Helps fill open role')),
        isTrue,
      );
    });

    test(
      'No matching skills yields 0% skills score and flags missing skills',
      () {
        final candidate = StudentProfile(
          id: 'cand_2',
          name: 'Bob',
          department: 'Electrical Engineering',
          semester: 7,
          skills: ['C++', 'Robotics'],
          interests: ['Robotics'],
          projectType: 'Final Year Project',
          availability: 'Full-time (20+ hrs/wk)',
          bio: 'Hardware engineer',
        );

        final breakdown = MatchingEngine.calculateMatch(
          candidate: candidate,
          currentUser: currentUser,
          currentTeam: currentTeam,
        );

        expect(breakdown.skillsScore, equals(0.0));
        expect(breakdown.skillsWeighted, equals(0.0));
        expect(breakdown.matchingSkills, isEmpty);
      },
    );

    test('Shared interests calculated via Jaccard index', () {
      final candidate = StudentProfile(
        id: 'cand_3',
        name: 'Charlie',
        department: 'Computer Science',
        semester: 7,
        skills: [],
        interests: [
          'Mobile Apps',
          'Cloud Computing',
        ], // 1 common with currentUser's 3
        projectType: 'Final Year Project',
        availability: 'Full-time (20+ hrs/wk)',
        bio: 'Cloud dev',
      );

      final breakdown = MatchingEngine.calculateMatch(
        candidate: candidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      // Union: Mobile Apps, AI, UI/UX, Cloud Computing = 4
      // Intersection: Mobile Apps = 1
      // Jaccard: 1/4 = 0.25 (25%)
      expect(breakdown.interestsScore, closeTo(25.0, 0.01));
      expect(breakdown.interestsWeighted, closeTo(6.25, 0.01));
    });

    test('No shared interests yields 0% interest score', () {
      final candidate = StudentProfile(
        id: 'cand_4',
        name: 'Dave',
        department: 'Software Engineering',
        semester: 7,
        skills: [],
        interests: ['Cybersecurity', 'Game Development'],
        projectType: 'Final Year Project',
        availability: 'Full-time (20+ hrs/wk)',
        bio: 'Game dev',
      );

      final breakdown = MatchingEngine.calculateMatch(
        candidate: candidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      expect(breakdown.interestsScore, equals(0.0));
      expect(breakdown.interestsWeighted, equals(0.0));
    });

    test('Project type match scores 100% and mismatch scores 0%', () {
      final matchCandidate = StudentProfile(
        id: 'cand_5',
        name: 'Eve',
        department: 'CS',
        semester: 7,
        skills: [],
        interests: [],
        projectType: 'Final Year Project',
        availability: 'Flexible',
        bio: 'Student',
      );

      final mismatchCandidate = StudentProfile(
        id: 'cand_6',
        name: 'Frank',
        department: 'CS',
        semester: 7,
        skills: [],
        interests: [],
        projectType: 'Semester Project', // Team wants FYP
        availability: 'Flexible',
        bio: 'Student',
      );

      final bothCandidate = StudentProfile(
        id: 'cand_7',
        name: 'Grace',
        department: 'CS',
        semester: 7,
        skills: [],
        interests: [],
        projectType: 'Both', // Compatible with FYP!
        availability: 'Flexible',
        bio: 'Student',
      );

      final bMatch = MatchingEngine.calculateMatch(
        candidate: matchCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );
      final bMismatch = MatchingEngine.calculateMatch(
        candidate: mismatchCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );
      final bBoth = MatchingEngine.calculateMatch(
        candidate: bothCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      expect(bMatch.projectTypeScore, equals(100.0));
      expect(bMatch.projectTypeWeighted, equals(20.0));

      expect(bMismatch.projectTypeScore, equals(0.0));
      expect(bMismatch.projectTypeWeighted, equals(0.0));

      expect(bBoth.projectTypeScore, equals(100.0));
      expect(bBoth.projectTypeWeighted, equals(20.0));
    });

    test('Availability compatibility and semester proximity decay', () {
      final sameSemCandidate = StudentProfile(
        id: 'cand_8',
        name: 'Heidi',
        department: 'SE',
        semester: 7, // Diff 0
        skills: [],
        interests: [],
        projectType: 'Final Year Project',
        availability: 'Full-time (20+ hrs/wk)', // Exact match
        bio: 'Student',
      );

      final diff3SemCandidate = StudentProfile(
        id: 'cand_9',
        name: 'Ivan',
        department: 'SE',
        semester: 4, // Diff 3
        skills: [],
        interests: [],
        projectType: 'Final Year Project',
        availability: 'Part-time (10-20 hrs/wk)',
        bio: 'Student',
      );

      final bSame = MatchingEngine.calculateMatch(
        candidate: sameSemCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );
      final bDiff = MatchingEngine.calculateMatch(
        candidate: diff3SemCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      // Same sem (100) + exact avail (100) = 100
      expect(bSame.availabilitySemesterScore, equals(100.0));
      expect(bSame.availabilitySemesterWeighted, equals(15.0));

      // Diff 3 (40) + partial avail (<100) => substantially lower
      expect(
        bDiff.availabilitySemesterScore,
        lessThan(bSame.availabilitySemesterScore),
      );
    });

    test('Score boundaries strictly enforced between 0 and 100', () {
      final perfectCandidate = StudentProfile(
        id: 'cand_10',
        name: 'Perfect Match',
        department: 'Software Engineering',
        semester: 7,
        skills: ['Python', 'Machine Learning'],
        interests: ['Mobile Apps', 'Artificial Intelligence', 'UI/UX'],
        projectType: 'Final Year Project',
        availability: 'Full-time (20+ hrs/wk)',
        bio: 'Perfect candidate',
      );

      final bPerfect = MatchingEngine.calculateMatch(
        candidate: perfectCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      expect(bPerfect.finalScore, inInclusiveRange(0, 100));
      expect(bPerfect.finalScore, equals(100));
      expect(bPerfect.label, equals('Excellent Match'));

      final zeroCandidate = StudentProfile(
        id: 'cand_11',
        name: 'Zero Match',
        department: 'Other',
        semester: 1,
        skills: ['None'],
        interests: ['None'],
        projectType: 'Incompatible',
        availability: 'None',
        bio: 'Zero',
      );

      final bZero = MatchingEngine.calculateMatch(
        candidate: zeroCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      expect(bZero.finalScore, inInclusiveRange(0, 100));
      expect(bZero.label, equals('Potential Match'));
    });

    test('Empty collections handled safely without exception', () {
      final emptyCandidate = StudentProfile(
        id: 'empty_cand',
        name: 'Empty',
        department: '',
        semester: 1,
        skills: [],
        interests: [],
        projectType: '',
        availability: '',
        bio: '',
      );

      expect(
        () => MatchingEngine.calculateMatch(
          candidate: emptyCandidate,
          currentUser: currentUser,
          currentTeam: currentTeam,
        ),
        returnsNormally,
      );
    });

    test('Skill Gap detection flags critical missing skills', () {
      final mlCandidate = StudentProfile(
        id: 'cand_gap',
        name: 'ML Pro',
        department: 'AI',
        semester: 7,
        skills: ['Python', 'Machine Learning'],
        interests: [],
        projectType: 'Final Year Project',
        availability: 'Flexible',
        bio: 'ML expert',
      );

      final breakdown = MatchingEngine.calculateMatch(
        candidate: mlCandidate,
        currentUser: currentUser,
        currentTeam: currentTeam,
      );

      expect(breakdown.bridgesSkillGap, isTrue);
      expect(
        breakdown.matchReasons.any((r) => r.contains('skill gap')),
        isTrue,
      );
    });

    test(
      'Deterministic results: multiple executions return exact identical scores',
      () {
        final candidate = StudentProfile(
          id: 'cand_repeat',
          name: 'Repeat Candidate',
          department: 'CS',
          semester: 6,
          skills: ['Python', 'Dart'],
          interests: ['Artificial Intelligence'],
          projectType: 'Both',
          availability: 'Flexible',
          bio: 'Consistency test candidate',
        );

        final b1 = MatchingEngine.calculateMatch(
          candidate: candidate,
          currentUser: currentUser,
          currentTeam: currentTeam,
        );
        final b2 = MatchingEngine.calculateMatch(
          candidate: candidate,
          currentUser: currentUser,
          currentTeam: currentTeam,
        );

        expect(b1.finalScore, equals(b2.finalScore));
        expect(b1.skillsScore, equals(b2.skillsScore));
        expect(b1.interestsScore, equals(b2.interestsScore));
        expect(b1.projectTypeScore, equals(b2.projectTypeScore));
        expect(
          b1.availabilitySemesterScore,
          equals(b2.availabilitySemesterScore),
        );
        expect(b1.matchReasons, equals(b2.matchReasons));
      },
    );
  });
}
