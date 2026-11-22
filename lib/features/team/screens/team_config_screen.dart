import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/team_provider.dart';

class TeamConfigScreen extends ConsumerStatefulWidget {
  const TeamConfigScreen({super.key});

  @override
  ConsumerState<TeamConfigScreen> createState() => _TeamConfigScreenState();
}

class _TeamConfigScreenState extends ConsumerState<TeamConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _projectType;

  // Add role dialog controllers
  final TextEditingController _roleTitleController = TextEditingController();
  final List<String> _tempRoleSkills = [];

  @override
  void initState() {
    super.initState();
    final team = ref.read(teamProvider).team;
    _titleController = TextEditingController(
      text: team?.title ?? 'Campus Project',
    );
    _descController = TextEditingController(text: team?.description ?? '');
    _projectType = team?.projectType ?? 'Final Year Project';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roleTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamProvider);
    final team = teamState.team;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Project Team'),
        actions: [
          TextButton(
            onPressed: _saveTeamConfig,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: team == null
          ? const Center(child: Text('No active team.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Project Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Project Title *',
                      hintText: 'e.g. Smart Campus Assistant',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Project title cannot be blank.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Project Type Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _projectType,
                    decoration: const InputDecoration(
                      labelText: 'Project Scope *',
                    ),
                    items: AppConstants.projectTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _projectType = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Project Description',
                      hintText:
                          'Summarize the goals and target architecture of your project...',
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Role Management Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Required Team Roles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${team.roles.length} total role slots defined',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _showAddRoleDialog,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Role'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Existing Roles List
                  ...team.roles.map((role) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: role.isOpen
                                    ? AppColors.statusPendingLight
                                    : AppColors.emeraldLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role.isOpen
                                    ? Icons.person_outline_rounded
                                    : Icons.person_rounded,
                                size: 18,
                                color: role.isOpen
                                    ? AppColors.statusPending
                                    : AppColors.accentEmerald,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          role.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: role.isOpen
                                              ? AppColors.statusPendingLight
                                              : AppColors.emeraldLight,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          role.isOpen ? 'OPEN' : 'FILLED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: role.isOpen
                                                ? AppColors.statusPending
                                                : AppColors.accentEmerald,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Required: ${role.requiredSkills.join(", ")}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (role.assignedMemberId != team.leaderId)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.statusRejected,
                                ),
                                onPressed: () {
                                  ref
                                      .read(teamProvider.notifier)
                                      .removeRole(role.id);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  void _saveTeamConfig() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(teamProvider.notifier)
        .updateTeamConfig(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          projectType: _projectType,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.accentEmerald,
        content: Text('Team configuration saved successfully!'),
      ),
    );
    Navigator.of(context).pop();
  }

  void _showAddRoleDialog() {
    _roleTitleController.clear();
    _tempRoleSkills.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Add Required Role Slot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _roleTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Role Title *',
                    hintText: 'e.g. AI / Machine Learning Engineer',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Required Skills for this Role',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AppConstants.suggestedSkills.take(12).map((skill) {
                    final isSelected = _tempRoleSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            _tempRoleSkills.add(skill);
                          } else {
                            _tempRoleSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _roleTitleController.text.trim();
                if (title.isNotEmpty) {
                  ref
                      .read(teamProvider.notifier)
                      .addRole(
                        title: title,
                        requiredSkills: List.from(_tempRoleSkills),
                      );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add Role'),
            ),
          ],
        ),
      ),
    );
  }
}
