import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  late String _selectedDepartment;
  late int _selectedSemester;
  late String _selectedProjectType;
  late String _selectedAvailability;

  late List<String> _skills;
  late List<String> _interests;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _selectedDepartment = profile.department.isNotEmpty
        ? profile.department
        : AppConstants.departments.first;
    _selectedSemester = profile.semester;
    _selectedProjectType = profile.projectType.isNotEmpty
        ? profile.projectType
        : AppConstants.projectTypes.first;
    _selectedAvailability = profile.availability.isNotEmpty
        ? profile.availability
        : AppConstants.availabilities.first;
    _skills = List.from(profile.skills);
    _interests = List.from(profile.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Academic Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Full Name (FR-1.2)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'e.g. Zayan Ahmed',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Full name cannot be blank.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Department (FR-1.2)
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department *',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              items: AppConstants.departments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDepartment = val);
              },
            ),
            const SizedBox(height: 16),

            // Semester (FR-1.2: 1 to 8)
            DropdownButtonFormField<int>(
              initialValue: _selectedSemester,
              decoration: const InputDecoration(
                labelText: 'Current Academic Semester (1 - 8) *',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: List.generate(8, (i) => i + 1).map((sem) {
                return DropdownMenuItem(
                  value: sem,
                  child: Text('Semester $sem'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSemester = val);
              },
            ),
            const SizedBox(height: 16),

            // Project Type (FR-1.2: Semester Project, FYP, Both)
            DropdownButtonFormField<String>(
              initialValue: _selectedProjectType,
              decoration: const InputDecoration(
                labelText: 'Project Type *',
                prefixIcon: Icon(Icons.assignment_outlined),
              ),
              items: AppConstants.projectTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedProjectType = val);
              },
            ),
            const SizedBox(height: 16),

            // Availability (FR-1.2)
            DropdownButtonFormField<String>(
              initialValue: _selectedAvailability,
              decoration: const InputDecoration(
                labelText: 'Weekly Availability *',
                prefixIcon: Icon(Icons.schedule_rounded),
              ),
              items: AppConstants.availabilities.map((avail) {
                return DropdownMenuItem(value: avail, child: Text(avail));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedAvailability = val);
              },
            ),
            const SizedBox(height: 16),

            // Short Bio (FR-1.2)
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 250,
              decoration: const InputDecoration(
                labelText: 'Short Bio *',
                hintText:
                    'Introduce your technical interests, project ambitions, or work ethics...',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Bio cannot be blank.';
                }
                if (val.trim().length < 10) {
                  return 'Bio must be at least 10 characters long.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Technical Skills Multi-Select (FR-1.2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Technical Skills * (Select at least one)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_skills.length} selected',
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
              children: AppConstants.suggestedSkills.map((skill) {
                final isSelected = _skills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _skills.add(skill);
                      } else {
                        _skills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_skills.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Please select at least one technical skill.',
                  style: TextStyle(
                    color: AppColors.statusRejected,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Areas of Interest Multi-Select (FR-1.2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Areas of Interest * (Select at least one)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_interests.length} selected',
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
              children: AppConstants.suggestedInterests.map((interest) {
                final isSelected = _interests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _interests.add(interest);
                      } else {
                        _interests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_interests.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Please select at least one area of interest.',
                  style: TextStyle(
                    color: AppColors.statusRejected,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile Changes'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    if (_skills.isEmpty || _interests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.statusRejected,
          content: Text('Please select at least one skill and one interest.'),
        ),
      );
      return;
    }

    final currentProfile = ref.read(profileProvider).profile;
    final updated = currentProfile.copyWith(
      name: _nameController.text.trim(),
      department: _selectedDepartment,
      semester: _selectedSemester,
      projectType: _selectedProjectType,
      availability: _selectedAvailability,
      bio: _bioController.text.trim(),
      skills: List.from(_skills),
      interests: List.from(_interests),
    );

    ref.read(profileProvider.notifier).updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.accentEmerald,
        content: Text('Academic profile updated and saved locally!'),
      ),
    );
    Navigator.of(context).pop();
  }
}
