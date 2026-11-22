import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/discover_provider.dart';

class FilterModal extends ConsumerStatefulWidget {
  const FilterModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FilterModal(),
    );
  }

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
  final TextEditingController _presetNameController = TextEditingController();

  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(discoverProvider);
    final notifier = ref.read(discoverProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slateLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (filterState.hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filterState.activeFilterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton(
                onPressed: () {
                  notifier.resetFilters();
                },
                child: const Text('Reset All'),
              ),
            ],
          ),

          const Divider(color: AppColors.border),

          // Scrollable filter content
          Expanded(
            child: ListView(
              children: [
                // 1. Saved Presets Section (FR-2.6 Bonus)
                if (filterState.savedPresets.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Presets',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showSavePresetDialog(context),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.bookmark_add_outlined,
                              size: 14,
                              color: AppColors.primaryIndigo,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Save Current',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryIndigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterState.savedPresets.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final preset = filterState.savedPresets[index];
                        return InputChip(
                          avatar: const Icon(
                            Icons.bookmark_rounded,
                            size: 14,
                            color: AppColors.primaryIndigo,
                          ),
                          label: Text(preset.name),
                          backgroundColor: AppColors.primaryIndigoLight,
                          onPressed: () {
                            notifier.applyPreset(preset);
                          },
                          onDeleted: () {
                            notifier.deletePreset(preset.id);
                          },
                          deleteIconColor: AppColors.secondarySlate,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                ],

                // 2. Department Filter
                const Text(
                  'Department',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('All Departments'),
                      selected: filterState.department == null,
                      onSelected: (selected) {
                        if (selected) notifier.setDepartment(null);
                      },
                    ),
                    ...AppConstants.departments.map((dept) {
                      final isSelected = filterState.department == dept;
                      return ChoiceChip(
                        label: Text(dept),
                        selected: isSelected,
                        onSelected: (selected) {
                          notifier.setDepartment(selected ? dept : null);
                        },
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Semester Range Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Semester Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      filterState.minSemester == null &&
                              filterState.maxSemester == null
                          ? 'Any Semester (1 - 8)'
                          : 'Sem ${filterState.minSemester ?? 1} - Sem ${filterState.maxSemester ?? 8}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('Any'),
                      selected:
                          filterState.minSemester == null &&
                          filterState.maxSemester == null,
                      onSelected: (selected) {
                        if (selected) notifier.setSemesterRange(null, null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Junior (1 - 4)'),
                      selected:
                          filterState.minSemester == 1 &&
                          filterState.maxSemester == 4,
                      onSelected: (selected) {
                        notifier.setSemesterRange(
                          selected ? 1 : null,
                          selected ? 4 : null,
                        );
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Senior (5 - 8)'),
                      selected:
                          filterState.minSemester == 5 &&
                          filterState.maxSemester == 8,
                      onSelected: (selected) {
                        notifier.setSemesterRange(
                          selected ? 5 : null,
                          selected ? 8 : null,
                        );
                      },
                    ),
                    ChoiceChip(
                      label: const Text('7th Sem Only'),
                      selected:
                          filterState.minSemester == 7 &&
                          filterState.maxSemester == 7,
                      onSelected: (selected) {
                        notifier.setSemesterRange(
                          selected ? 7 : null,
                          selected ? 7 : null,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. Project Type Filter
                const Text(
                  'Project Type Scope',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('All Types'),
                      selected: filterState.projectType == null,
                      onSelected: (selected) {
                        if (selected) notifier.setProjectType(null);
                      },
                    ),
                    ...AppConstants.projectTypes.map((type) {
                      final isSelected = filterState.projectType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          notifier.setProjectType(selected ? type : null);
                        },
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 16),

                // 5. Skills Multi-Select Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Skills Filter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (filterState.selectedSkills.isNotEmpty)
                      Text(
                        '${filterState.selectedSkills.length} selected',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AppConstants.suggestedSkills.take(16).map((skill) {
                    final isSelected = filterState.selectedSkills.contains(
                      skill,
                    );
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (_) {
                        notifier.toggleSkill(skill);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showSavePresetDialog(context),
                  child: const Text('Save Preset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSavePresetDialog(BuildContext context) {
    _presetNameController.text = 'Custom Filter';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Save Filter Preset'),
        content: TextField(
          controller: _presetNameController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            hintText: 'e.g. Flutter Mobile Seniors',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _presetNameController.text.trim();
              if (name.isNotEmpty) {
                ref.read(discoverProvider.notifier).saveCurrentPreset(name);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preset "$name" saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
