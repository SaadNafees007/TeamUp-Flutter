import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/discover_provider.dart';
import '../widgets/student_card.dart';
import '../widgets/filter_modal.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = ref.watch(filteredStudentsProvider);
    final filterState = ref.watch(discoverProvider);
    final notifier = ref.read(discoverProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover Students',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${filteredStudents.length} candidates available',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Filter Button with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Filters & Presets',
                onPressed: () {
                  FilterModal.show(context);
                },
              ),
              if (filterState.hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryIndigo,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${filterState.activeFilterCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Sorting Menu (FR-2.5 Bonus)
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.textPrimary),
            tooltip: 'Sort Candidates',
            initialValue: filterState.sortOption,
            onSelected: (option) {
              notifier.setSortOption(option);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.matchScore,
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: AppColors.primaryIndigo,
                    ),
                    SizedBox(width: 8),
                    Text('Match Score: Highest First'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.semester,
                child: Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 18,
                      color: AppColors.secondarySlate,
                    ),
                    SizedBox(width: 8),
                    Text('Semester: Senior First'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha_rounded,
                      size: 18,
                      color: AppColors.secondarySlate,
                    ),
                    SizedBox(width: 8),
                    Text('Alphabetical Name'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                notifier.setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search by student name or skill (e.g. Flutter)...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.secondarySlate,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Active filter chip row if filters are active
          if (filterState.hasActiveFilters)
            Container(
              height: 38,
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (filterState.department != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text('Dept: ${filterState.department}'),
                        onDeleted: () => notifier.setDepartment(null),
                      ),
                    ),
                  if (filterState.minSemester != null ||
                      filterState.maxSemester != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(
                          'Sem ${filterState.minSemester ?? 1}-${filterState.maxSemester ?? 8}',
                        ),
                        onDeleted: () => notifier.setSemesterRange(null, null),
                      ),
                    ),
                  if (filterState.projectType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(filterState.projectType!),
                        onDeleted: () => notifier.setProjectType(null),
                      ),
                    ),
                  ...filterState.selectedSkills.map(
                    (skill) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(skill),
                        onDeleted: () => notifier.toggleSkill(skill),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Students List or Empty State
          Expanded(
            child: filteredStudents.isEmpty
                ? EmptyState(
                    icon: Icons.person_search_rounded,
                    title: 'No Students Found',
                    message:
                        'No student profiles match your search criteria. Try modifying your search term or resetting your active filters.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      notifier.resetFilters();
                    },
                  )
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return StudentCard(student: student);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
