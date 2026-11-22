import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/match_breakdown.dart';
import '../../../data/local_storage/local_store.dart';
import '../services/matching_engine.dart';
import '../../profile/providers/profile_provider.dart';
import '../../team/providers/team_provider.dart';

class MatchItem {
  final StudentProfile student;
  final MatchBreakdown breakdown;

  MatchItem({required this.student, required this.breakdown});
}

final bestMatchesProvider = Provider<List<MatchItem>>((ref) {
  final profileState = ref.watch(profileProvider);
  final teamState = ref.watch(teamProvider);

  final currentUser = profileState.profile;
  final currentTeam = teamState.team;
  final allStudents = LocalStore.getStudents();

  final List<MatchItem> results = [];

  for (final student in allStudents) {
    if (student.id == currentUser.id) continue;

    final breakdown = MatchingEngine.calculateMatch(
      candidate: student,
      currentUser: currentUser,
      currentTeam: currentTeam,
    );

    results.add(MatchItem(student: student, breakdown: breakdown));
  }

  // Strict descending order of calculated match score (FR-3.2)
  results.sort(
    (a, b) => b.breakdown.finalScore.compareTo(a.breakdown.finalScore),
  );

  return results;
});

final candidateMatchProvider = Provider.family<MatchBreakdown, StudentProfile>((
  ref,
  candidate,
) {
  final profileState = ref.watch(profileProvider);
  final teamState = ref.watch(teamProvider);

  return MatchingEngine.calculateMatch(
    candidate: candidate,
    currentUser: profileState.profile,
    currentTeam: teamState.team,
  );
});
