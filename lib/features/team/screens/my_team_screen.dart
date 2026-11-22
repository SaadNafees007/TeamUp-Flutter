import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/team_role.dart';
import '../../../data/local_storage/local_store.dart';
import '../providers/team_provider.dart';
import 'team_config_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../chat/screens/chat_screen.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamState = ref.watch(teamProvider);
    final team = teamState.team;
    final skillGap = teamState.skillGap;

    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Team')),
        body: EmptyState(
          icon: Icons.groups_rounded,
          title: 'No Active Team',
          message:
              'You have not set up a project team yet. Create one to organize roles, track tasks, and collaborate with teammates.',
          buttonText: 'Create Team',
          onButtonPressed: () {
            ref
                .read(teamProvider.notifier)
                .updateTeamConfig(
                  title: 'Smart Campus Assistant',
                  description:
                      'An AI-driven campus assistant for COMSATS students and faculty.',
                  projectType: 'Final Year Project',
                );
          },
        ),
      );
    }

    final allStudents = LocalStore.getStudents();
    final currentUser = LocalStore.getCurrentUser();

    // Map member IDs to StudentProfile
    final List<StudentProfile> members = [];
    for (final id in team.memberIds) {
      if (id == currentUser.id) {
        members.add(currentUser);
      } else {
        final found = allStudents.firstWhere(
          (s) => s.id == id,
          orElse: () => StudentProfile(
            id: id,
            name: 'Teammate',
            department: 'Computer Science',
            semester: 7,
            skills: [],
            interests: [],
            projectType: 'Final Year Project',
            availability: 'Flexible',
            bio: '',
          ),
        );
        members.add(found);
      }
    }

    final openRoles = team.roles.where((r) => r.isOpen).toList();

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
                Icons.group_work_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Project Team',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Team Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeamConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // 1. Team Overview Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        team.projectType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TeamConfigScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  team.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                if (team.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    team.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Metrics Row (Competition constraint: max 3 members)
                Row(
                  children: [
                    _buildMetricPill(
                      icon: Icons.people_rounded,
                      label: 'Members',
                      value: '${team.totalMembersCount}/${AppConstants.maxTeamSize}',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricPill(
                      icon: Icons.person_add_alt_1_rounded,
                      label: team.totalMembersCount >= AppConstants.maxTeamSize ? 'Status' : 'Open Slots',
                      value: team.totalMembersCount >= AppConstants.maxTeamSize ? 'Team Full' : '${AppConstants.maxTeamSize - team.totalMembersCount}',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricPill(
                      icon: Icons.verified_rounded,
                      label: 'Skill Match',
                      value: '${skillGap.coveragePercentage}%',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Collaboration Shortcuts (Tasks & Chat)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TasksScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryIndigoLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.checklist_rounded,
                            color: AppColors.primaryIndigo,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tasks',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${teamState.tasks.length} items',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.forum_rounded,
                            color: AppColors.accentEmerald,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Local Chat',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${teamState.chatMessages.length} msgs',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Skill Gap Analysis (FR-3.5 Bonus)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          color: AppColors.primaryIndigo,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Team Skill Gap Analysis',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: skillGap.coveragePercentage >= 80
                            ? AppColors.emeraldLight
                            : AppColors.primaryIndigoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${skillGap.coveragePercentage}% Covered',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: skillGap.coveragePercentage >= 80
                              ? AppColors.accentEmerald
                              : AppColors.primaryIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: skillGap.coveragePercentage / 100.0,
                    backgroundColor: AppColors.slateLight,
                    color: skillGap.coveragePercentage >= 80
                        ? AppColors.accentEmerald
                        : AppColors.primaryIndigo,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 14),

                // Covered Skills
                const Text(
                  'Covered by Active Team:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: skillGap.coveredSkills.isNotEmpty
                      ? skillGap.coveredSkills
                            .map(
                              (s) => SkillChip(skill: s, isHighlighted: true),
                            )
                            .toList()
                      : [
                          const Text(
                            'No team skills recorded yet.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                ),

                const SizedBox(height: 12),

                // Missing Skills (Skill Gaps)
                const Text(
                  'Missing Project Skills (Gaps):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusRejected,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: skillGap.missingSkills.isNotEmpty
                      ? skillGap.missingSkills.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusRejectedLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.statusRejected.withValues(alpha: 
                                  0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 12,
                                  color: AppColors.statusRejected,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.statusRejected,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      : [
                          const Text(
                            'Full skill coverage achieved! All role requirements met.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentEmerald,
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Active Team Roster (FR-5.2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Roster (${members.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Leader: ${currentUser.name.split(" ").first}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Member Cards
          ...members.map((member) {
            final isLeader = member.id == team.leaderId;
            final roleId = team.memberRoleMap[member.id];
            final role = team.roles.firstWhere(
              (r) => r.id == roleId,
              orElse: () => TeamRole(
                id: 'unassigned',
                title: isLeader ? 'Team Leader' : 'Team Member',
                requiredSkills: [],
              ),
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    AvatarWidget(
                      avatarKey: member.avatar,
                      name: member.name,
                      radius: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isLeader) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryIndigoLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LEAD',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryIndigo,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            role.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryIndigoDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.skills.take(3).join(', '),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLeader)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 20,
                          color: AppColors.statusRejected,
                        ),
                        tooltip: 'Remove Member',
                        onPressed: () =>
                            _handleRemoveMember(context, ref, member),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 4. Open Role Slots (FR-5.2)
          Text(
            'Open Role Slots (${openRoles.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          if (openRoles.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.emeraldLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accentEmerald,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'All roles are currently filled!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            )
          else
            ...openRoles.map((role) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.statusPending.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.statusPendingLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 20,
                        color: AppColors.statusPending,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Required Skills: ${role.requiredSkills.join(", ")}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRemoveMember(
    BuildContext context,
    WidgetRef ref,
    StudentProfile member,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Remove Team Member',
      message:
          'Are you sure you want to remove ${member.name} from the project team? Their assigned role will become open.',
      confirmText: 'Remove Member',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(teamProvider.notifier).removeMember(member.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.name} removed from team.')),
        );
      }
    }
  }
}
