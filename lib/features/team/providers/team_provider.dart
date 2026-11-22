import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/team.dart';
import '../../../data/models/team_role.dart';
import '../../../data/models/team_task.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/local_storage/local_store.dart';

class TeamSkillGap {
  final List<String> requiredSkills;
  final List<String> coveredSkills;
  final List<String> missingSkills;
  final int coveragePercentage;

  TeamSkillGap({
    required this.requiredSkills,
    required this.coveredSkills,
    required this.missingSkills,
    required this.coveragePercentage,
  });
}

class TeamState {
  final Team? team;
  final List<TeamTask> tasks;
  final List<ChatMessage> chatMessages;
  final TeamSkillGap skillGap;

  TeamState({
    required this.team,
    required this.tasks,
    required this.chatMessages,
    required this.skillGap,
  });

  TeamState copyWith({
    Team? team,
    bool clearTeam = false,
    List<TeamTask>? tasks,
    List<ChatMessage>? chatMessages,
    TeamSkillGap? skillGap,
  }) {
    return TeamState(
      team: clearTeam ? null : (team ?? this.team),
      tasks: tasks ?? this.tasks,
      chatMessages: chatMessages ?? this.chatMessages,
      skillGap: skillGap ?? this.skillGap,
    );
  }
}

class TeamNotifier extends StateNotifier<TeamState> {
  TeamNotifier() : super(_initialState());

  static TeamState _initialState() {
    final team = LocalStore.getTeam();
    final tasks = LocalStore.getTasks();
    final msgs = LocalStore.getChatMessages();
    final user = LocalStore.getCurrentUser();
    final students = LocalStore.getStudents();
    final gap = _computeSkillGap(team, user, students);
    return TeamState(
      team: team,
      tasks: tasks,
      chatMessages: msgs,
      skillGap: gap,
    );
  }

  static TeamSkillGap _computeSkillGap(
    Team? team,
    StudentProfile currentUser,
    List<StudentProfile> allStudents,
  ) {
    if (team == null || team.roles.isEmpty) {
      return TeamSkillGap(
        requiredSkills: [],
        coveredSkills: [],
        missingSkills: [],
        coveragePercentage: 100,
      );
    }

    final Set<String> required = {};
    for (final role in team.roles) {
      for (final s in role.requiredSkills) {
        required.add(s.trim());
      }
    }

    // Identify skills of all current team members
    final Set<String> teamSkills = {};
    for (final s in currentUser.skills) {
      teamSkills.add(s.trim().toLowerCase());
    }

    // Add accepted members skills
    for (final memberId in team.memberIds) {
      if (memberId == currentUser.id) continue;
      final student = allStudents.firstWhere(
        (s) => s.id == memberId,
        orElse: () => StudentProfile(
          id: memberId,
          name: 'Member',
          department: '',
          semester: 1,
          skills: [],
          interests: [],
          projectType: '',
          availability: '',
          bio: '',
        ),
      );
      for (final s in student.skills) {
        teamSkills.add(s.trim().toLowerCase());
      }
    }

    final List<String> covered = [];
    final List<String> missing = [];

    for (final req in required) {
      if (teamSkills.contains(req.toLowerCase())) {
        covered.add(req);
      } else {
        missing.add(req);
      }
    }

    final int pct = required.isEmpty
        ? 100
        : ((covered.length / required.length) * 100).round().clamp(0, 100);

    return TeamSkillGap(
      requiredSkills: required.toList(),
      coveredSkills: covered,
      missingSkills: missing,
      coveragePercentage: pct,
    );
  }

  void _refreshGap() {
    final user = LocalStore.getCurrentUser();
    final students = LocalStore.getStudents();
    final gap = _computeSkillGap(state.team, user, students);
    state = state.copyWith(skillGap: gap);
  }

  // 1. Team Configuration & Roles
  Future<void> updateTeamConfig({
    required String title,
    required String description,
    required String projectType,
  }) async {
    if (state.team == null) return;
    final updated = state.team!.copyWith(
      title: title,
      description: description,
      projectType: projectType,
    );
    await LocalStore.saveTeam(updated);
    state = state.copyWith(team: updated);
    _refreshGap();
  }

  Future<void> addRole({
    required String title,
    required List<String> requiredSkills,
  }) async {
    if (state.team == null) return;
    final newRole = TeamRole(
      id: 'role_${const Uuid().v4().substring(0, 8)}',
      title: title,
      requiredSkills: requiredSkills,
    );
    final updatedRoles = [...state.team!.roles, newRole];
    final updatedTeam = state.team!.copyWith(roles: updatedRoles);
    await LocalStore.saveTeam(updatedTeam);
    state = state.copyWith(team: updatedTeam);
    _refreshGap();
  }

  Future<void> removeRole(String roleId) async {
    if (state.team == null) return;
    final updatedRoles = state.team!.roles
        .where((r) => r.id != roleId)
        .toList();
    final updatedMap = Map<String, String>.from(state.team!.memberRoleMap);
    updatedMap.removeWhere((_, rId) => rId == roleId);
    final updatedTeam = state.team!.copyWith(
      roles: updatedRoles,
      memberRoleMap: updatedMap,
    );
    await LocalStore.saveTeam(updatedTeam);
    state = state.copyWith(team: updatedTeam);
    _refreshGap();
  }

  // 2. Automatic Roster Synchronization (FR-5.3)
  /// Adds accepted candidate to active team, assigns to best matching open role, updates skill gap
  Future<void> addMemberWithAutoRole(StudentProfile student) async {
    if (state.team == null) return;
    final team = state.team!;
    if (team.memberIds.contains(student.id)) return; // Avoid duplicates
    // Enforce competition constraint: max 3 members
    if (team.memberIds.length >= AppConstants.maxTeamSize) return;

    final updatedMembers = [...team.memberIds, student.id];
    final updatedRoles = List<TeamRole>.from(team.roles);
    final updatedMap = Map<String, String>.from(team.memberRoleMap);

    // Find best open role for this student's skills
    final openRoles = updatedRoles.where((r) => r.isOpen).toList();
    TeamRole? bestRole;
    int maxMatches = -1;

    final candidateSkills = student.skills
        .map((s) => s.trim().toLowerCase())
        .toSet();

    for (final role in openRoles) {
      int matches = 0;
      for (final req in role.requiredSkills) {
        if (candidateSkills.contains(req.trim().toLowerCase())) {
          matches++;
        }
      }
      if (matches > maxMatches) {
        maxMatches = matches;
        bestRole = role;
      }
    }

    if (bestRole != null) {
      // Assign student to this role
      final index = updatedRoles.indexWhere((r) => r.id == bestRole!.id);
      if (index != -1) {
        updatedRoles[index] = bestRole.copyWith(assignedMemberId: student.id);
        updatedMap[student.id] = bestRole.id;
      }
    }

    final updatedTeam = team.copyWith(
      memberIds: updatedMembers,
      roles: updatedRoles,
      memberRoleMap: updatedMap,
    );

    await LocalStore.saveTeam(updatedTeam);
    state = state.copyWith(team: updatedTeam);
    _refreshGap();

    // Add a celebratory notification in local chat
    await addChatMessage(
      senderId: 'system',
      senderName: 'TeamUp Bot',
      message:
          '${student.name} was accepted and joined the team! ${bestRole != null ? "Assigned role: ${bestRole.title}." : "Added as team collaborator."}',
      isMe: false,
    );
  }

  Future<void> removeMember(String memberId) async {
    if (state.team == null) return;
    final team = state.team!;
    if (memberId == team.leaderId) return; // Cannot remove leader

    final updatedMembers = team.memberIds
        .where((id) => id != memberId)
        .toList();
    final updatedRoles = team.roles.map((role) {
      if (role.assignedMemberId == memberId) {
        return role.copyWith(clearAssigned: true);
      }
      return role;
    }).toList();

    final updatedMap = Map<String, String>.from(team.memberRoleMap);
    updatedMap.remove(memberId);

    final updatedTeam = team.copyWith(
      memberIds: updatedMembers,
      roles: updatedRoles,
      memberRoleMap: updatedMap,
    );

    await LocalStore.saveTeam(updatedTeam);
    state = state.copyWith(team: updatedTeam);
    _refreshGap();
  }

  Future<void> leaveTeam() async {
    // Reset or disband team
    await LocalStore.saveTeam(null);
    state = state.copyWith(clearTeam: true);
    _refreshGap();
  }

  // 3. Interactive Tasks (FR-5.5 Bonus)
  Future<void> addTask({required String title, String description = ''}) async {
    final newTask = TeamTask(
      id: 'task_${const Uuid().v4().substring(0, 8)}',
      title: title.trim(),
      description: description.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
      assignedMemberId: LocalStore.getCurrentUser().id,
    );
    final updated = [newTask, ...state.tasks];
    await LocalStore.saveTasks(updated);
    state = state.copyWith(tasks: updated);
  }

  Future<void> toggleTask(String taskId) async {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(isCompleted: !t.isCompleted);
      }
      return t;
    }).toList();
    await LocalStore.saveTasks(updated);
    state = state.copyWith(tasks: updated);
  }

  Future<void> deleteTask(String taskId) async {
    final updated = state.tasks.where((t) => t.id != taskId).toList();
    await LocalStore.saveTasks(updated);
    state = state.copyWith(tasks: updated);
  }

  // 4. Simulated Local Chat (FR-5.6 Bonus)
  Future<void> addChatMessage({
    required String senderId,
    required String senderName,
    required String message,
    required bool isMe,
  }) async {
    final newMsg = ChatMessage(
      id: 'msg_${const Uuid().v4().substring(0, 8)}',
      senderId: senderId,
      senderName: senderName,
      message: message.trim(),
      timestamp: DateTime.now(),
      isMe: isMe,
    );
    final updated = [...state.chatMessages, newMsg];
    await LocalStore.saveChatMessages(updated);
    state = state.copyWith(chatMessages: updated);
  }

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;
    final currentUser = LocalStore.getCurrentUser();
    await addChatMessage(
      senderId: currentUser.id,
      senderName: '${currentUser.name} (Lead)',
      message: text,
      isMe: true,
    );

    // Simulate an offline bot / teammate feedback after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () async {
      final replies = [
        'Great point! I will sync up on the task checklist.',
        'Noted. Reviewing the project requirements now.',
        'Agreed, let us keep our code clean and well-documented.',
      ];
      final randomReply = (replies..shuffle()).first;
      await addChatMessage(
        senderId: 'sim_teammate',
        senderName: 'Simulated Teammate',
        message: randomReply,
        isMe: false,
      );
    });
  }
}

final teamProvider = StateNotifierProvider<TeamNotifier, TeamState>((ref) {
  return TeamNotifier();
});
