import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/filter_preset.dart';
import '../../../data/local_storage/local_store.dart';
import '../../matching/services/matching_engine.dart';
import '../../profile/providers/profile_provider.dart';
import '../../team/providers/team_provider.dart';

enum SortOption { matchScore, semester, alphabetical }

class DiscoverFilterState {
  final String searchQuery;
  final String? department;
  final int? minSemester;
  final int? maxSemester;
  final List<String> selectedSkills;
  final String? projectType;
  final SortOption sortOption;
  final List<FilterPreset> savedPresets;

  DiscoverFilterState({
    this.searchQuery = '',
    this.department,
    this.minSemester,
    this.maxSemester,
    this.selectedSkills = const [],
    this.projectType,
    this.sortOption = SortOption.matchScore,
    this.savedPresets = const [],
  });

  bool get hasActiveFilters =>
      department != null ||
      minSemester != null ||
      maxSemester != null ||
      selectedSkills.isNotEmpty ||
      projectType != null;

  int get activeFilterCount {
    int count = 0;
    if (department != null) count++;
    if (minSemester != null || maxSemester != null) count++;
    if (selectedSkills.isNotEmpty) count += selectedSkills.length;
    if (projectType != null) count++;
    return count;
  }

  DiscoverFilterState copyWith({
    String? searchQuery,
    String? department,
    bool clearDepartment = false,
    int? minSemester,
    bool clearMinSemester = false,
    int? maxSemester,
    bool clearMaxSemester = false,
    List<String>? selectedSkills,
    String? projectType,
    bool clearProjectType = false,
    SortOption? sortOption,
    List<FilterPreset>? savedPresets,
  }) {
    return DiscoverFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      department: clearDepartment ? null : (department ?? this.department),
      minSemester: clearMinSemester ? null : (minSemester ?? this.minSemester),
      maxSemester: clearMaxSemester ? null : (maxSemester ?? this.maxSemester),
      selectedSkills: selectedSkills ?? this.selectedSkills,
      projectType: clearProjectType ? null : (projectType ?? this.projectType),
      sortOption: sortOption ?? this.sortOption,
      savedPresets: savedPresets ?? this.savedPresets,
    );
  }
}

class DiscoverNotifier extends StateNotifier<DiscoverFilterState> {
  DiscoverNotifier()
    : super(DiscoverFilterState(savedPresets: LocalStore.getFilterPresets()));

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDepartment(String? dept) {
    state = state.copyWith(department: dept, clearDepartment: dept == null);
  }

  void setSemesterRange(int? min, int? max) {
    state = state.copyWith(
      minSemester: min,
      clearMinSemester: min == null,
      maxSemester: max,
      clearMaxSemester: max == null,
    );
  }

  void toggleSkill(String skill) {
    final current = List<String>.from(state.selectedSkills);
    if (current.contains(skill)) {
      current.remove(skill);
    } else {
      current.add(skill);
    }
    state = state.copyWith(selectedSkills: current);
  }

  void setProjectType(String? type) {
    state = state.copyWith(projectType: type, clearProjectType: type == null);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void resetFilters() {
    state = DiscoverFilterState(
      searchQuery: state.searchQuery,
      sortOption: state.sortOption,
      savedPresets: state.savedPresets,
    );
  }

  // Saved Presets (FR-2.6 Bonus)
  Future<void> saveCurrentPreset(String name) async {
    final newPreset = FilterPreset(
      id: 'preset_${const Uuid().v4().substring(0, 8)}',
      name: name.trim(),
      department: state.department,
      minSemester: state.minSemester,
      maxSemester: state.maxSemester,
      skills: state.selectedSkills,
      projectType: state.projectType,
    );
    final updated = [...state.savedPresets, newPreset];
    await LocalStore.saveFilterPresets(updated);
    state = state.copyWith(savedPresets: updated);
  }

  void applyPreset(FilterPreset preset) {
    state = state.copyWith(
      department: preset.department,
      clearDepartment: preset.department == null,
      minSemester: preset.minSemester,
      clearMinSemester: preset.minSemester == null,
      maxSemester: preset.maxSemester,
      clearMaxSemester: preset.maxSemester == null,
      selectedSkills: List<String>.from(preset.skills),
      projectType: preset.projectType,
      clearProjectType: preset.projectType == null,
    );
  }

  Future<void> deletePreset(String presetId) async {
    final updated = state.savedPresets.where((p) => p.id != presetId).toList();
    await LocalStore.saveFilterPresets(updated);
    state = state.copyWith(savedPresets: updated);
  }
}

final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverFilterState>((ref) {
      return DiscoverNotifier();
    });

/// Filtered & Sorted candidates provider for the Discover screen
final filteredStudentsProvider = Provider<List<StudentProfile>>((ref) {
  final filterState = ref.watch(discoverProvider);
  final profileState = ref.watch(profileProvider);
  final teamState = ref.watch(teamProvider);

  final currentUser = profileState.profile;
  final currentTeam = teamState.team;
  final allStudents = LocalStore.getStudents();

  // 1. Exclude current user
  List<StudentProfile> result = allStudents
      .where((s) => s.id != currentUser.id)
      .toList();

  // 2. Real-time Search (Name or Skills)
  if (filterState.searchQuery.trim().isNotEmpty) {
    final query = filterState.searchQuery.trim().toLowerCase();
    result = result.where((s) {
      final nameMatches = s.name.toLowerCase().contains(query);
      final skillMatches = s.skills.any(
        (sk) => sk.toLowerCase().contains(query),
      );
      return nameMatches || skillMatches;
    }).toList();
  }

  // 3. Multi-Criteria Filtering (FR-2.4)
  if (filterState.department != null) {
    result = result
        .where(
          (s) =>
              s.department.toLowerCase() ==
              filterState.department!.toLowerCase(),
        )
        .toList();
  }

  if (filterState.minSemester != null) {
    result = result
        .where((s) => s.semester >= filterState.minSemester!)
        .toList();
  }

  if (filterState.maxSemester != null) {
    result = result
        .where((s) => s.semester <= filterState.maxSemester!)
        .toList();
  }

  if (filterState.selectedSkills.isNotEmpty) {
    result = result.where((s) {
      final studentSkillsLower = s.skills.map((sk) => sk.toLowerCase()).toSet();
      return filterState.selectedSkills.any(
        (sk) => studentSkillsLower.contains(sk.toLowerCase()),
      );
    }).toList();
  }

  if (filterState.projectType != null) {
    result = result.where((s) {
      if (s.projectType == 'Both' || filterState.projectType == 'Both') {
        return true;
      }
      return s.projectType.toLowerCase() ==
          filterState.projectType!.toLowerCase();
    }).toList();
  }

  // 4. Dynamic Sorting (FR-2.5 Bonus)
  switch (filterState.sortOption) {
    case SortOption.matchScore:
      result.sort((a, b) {
        final scoreA = MatchingEngine.calculateMatch(
          candidate: a,
          currentUser: currentUser,
          currentTeam: currentTeam,
        ).finalScore;
        final scoreB = MatchingEngine.calculateMatch(
          candidate: b,
          currentUser: currentUser,
          currentTeam: currentTeam,
        ).finalScore;
        return scoreB.compareTo(scoreA); // Highest first
      });
      break;
    case SortOption.semester:
      result.sort((a, b) => b.semester.compareTo(a.semester));
      break;
    case SortOption.alphabetical:
      result.sort((a, b) => a.name.compareTo(b.name));
      break;
  }

  return result;
});
