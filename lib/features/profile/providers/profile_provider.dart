import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/local_storage/local_store.dart';

class ProfileState {
  final StudentProfile profile;
  final int completenessPercentage;
  final String completenessFeedback;

  ProfileState({
    required this.profile,
    required this.completenessPercentage,
    required this.completenessFeedback,
  });

  ProfileState copyWith({
    StudentProfile? profile,
    int? completenessPercentage,
    String? completenessFeedback,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      completenessPercentage:
          completenessPercentage ?? this.completenessPercentage,
      completenessFeedback: completenessFeedback ?? this.completenessFeedback,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(_calculateInitialState());

  static ProfileState _calculateInitialState() {
    final user = LocalStore.getCurrentUser();
    return _buildState(user);
  }

  static ProfileState _buildState(StudentProfile profile) {
    int score = 0;
    final List<String> missingFields = [];

    // Full Name: 10%
    if (profile.name.trim().isNotEmpty) {
      score += 10;
    } else {
      missingFields.add('Full Name');
    }

    // Department: 10%
    if (profile.department.trim().isNotEmpty) {
      score += 10;
    } else {
      missingFields.add('Department');
    }

    // Semester: 10% (competition constraint: 4-8 eligible)
    if (profile.semester >= 4 && profile.semester <= 8) {
      score += 10;
    } else {
      missingFields.add('Semester');
    }

    // Skills: 15%
    if (profile.skills.isNotEmpty) {
      score += 15;
    } else {
      missingFields.add('Skills');
    }

    // Interests: 15%
    if (profile.interests.isNotEmpty) {
      score += 15;
    } else {
      missingFields.add('Interests');
    }

    // Project Type: 10%
    if (profile.projectType.trim().isNotEmpty) {
      score += 10;
    } else {
      missingFields.add('Project Type');
    }

    // Availability: 10%
    if (profile.availability.trim().isNotEmpty) {
      score += 10;
    } else {
      missingFields.add('Availability');
    }

    // Bio: 10%
    if (profile.bio.trim().length >= 10) {
      score += 10;
    } else {
      missingFields.add('Detailed Bio');
    }

    // Avatar: 10%
    if (profile.avatar.trim().isNotEmpty) {
      score += 10;
    } else {
      missingFields.add('Avatar');
    }

    final percentage = score.clamp(0, 100);
    String feedback;
    if (percentage == 100) {
      feedback = 'All set! Your profile is 100% complete and verified.';
    } else if (missingFields.isNotEmpty) {
      feedback =
          'Your profile is $percentage% complete. Add ${missingFields.first} to boost your visibility!';
    } else {
      feedback = 'Your profile is $percentage% complete.';
    }

    return ProfileState(
      profile: profile,
      completenessPercentage: percentage,
      completenessFeedback: feedback,
    );
  }

  Future<void> updateProfile(StudentProfile updated) async {
    await LocalStore.saveCurrentUser(updated);
    state = _buildState(updated);
  }

  Future<void> updateAvatar(String newAvatarKey) async {
    final updated = state.profile.copyWith(avatar: newAvatarKey);
    await updateProfile(updated);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
