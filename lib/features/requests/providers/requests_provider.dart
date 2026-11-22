import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/team_request.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/local_storage/local_store.dart';
import '../../team/providers/team_provider.dart';

class RequestsState {
  final List<TeamRequest> requests;
  final int pendingIncomingCount;

  RequestsState({required this.requests, required this.pendingIncomingCount});

  List<TeamRequest> get receivedRequests {
    final currentUserId = LocalStore.getCurrentUser().id;
    return requests.where((r) => r.receiverId == currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TeamRequest> get sentRequests {
    final currentUserId = LocalStore.getCurrentUser().id;
    return requests.where((r) => r.senderId == currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  final Ref _ref;

  RequestsNotifier(this._ref) : super(_calculateInitialState());

  static RequestsState _calculateInitialState() {
    final reqs = LocalStore.getRequests();
    final currentUserId = LocalStore.getCurrentUser().id;
    final pendingCount = reqs
        .where(
          (r) =>
              r.receiverId == currentUserId &&
              r.status == 'pending' &&
              !r.isExpired,
        )
        .length;
    return RequestsState(requests: reqs, pendingIncomingCount: pendingCount);
  }

  void _updateStateWith(List<TeamRequest> updatedList) {
    final currentUserId = LocalStore.getCurrentUser().id;
    final pendingCount = updatedList
        .where(
          (r) =>
              r.receiverId == currentUserId &&
              r.status == 'pending' &&
              !r.isExpired,
        )
        .length;
    state = RequestsState(
      requests: updatedList,
      pendingIncomingCount: pendingCount,
    );
  }

  Future<bool> sendRequest({
    required String receiverId,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return false;

    final currentUserId = LocalStore.getCurrentUser().id;

    // Check if an active pending request already exists between these two
    final existing = state.requests.any(
      (r) =>
          r.senderId == currentUserId &&
          r.receiverId == receiverId &&
          r.status == 'pending' &&
          !r.isExpired,
    );
    if (existing) return false;

    final now = DateTime.now();
    final newRequest = TeamRequest(
      id: 'req_${const Uuid().v4().substring(0, 8)}',
      senderId: currentUserId,
      receiverId: receiverId,
      message: trimmed,
      status: 'pending',
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 72)),
    );

    final updated = [newRequest, ...state.requests];
    await LocalStore.saveRequests(updated);
    _updateStateWith(updated);
    return true;
  }

  Future<void> acceptRequest(String requestId) async {
    final currentRequests = List<TeamRequest>.from(state.requests);
    final index = currentRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    // Enforce competition constraint: max 3 members (including leader)
    final teamState = _ref.read(teamProvider);
    if (teamState.team != null &&
        teamState.team!.memberIds.length >= AppConstants.maxTeamSize) {
      return; // Team is full — silently block (UI should also disable button)
    }

    final request = currentRequests[index];
    final updatedRequest = request.copyWith(status: 'accepted');
    currentRequests[index] = updatedRequest;

    await LocalStore.saveRequests(currentRequests);
    _updateStateWith(currentRequests);

    // Automatic Roster Synchronization (FR-5.3)
    final allStudents = LocalStore.getStudents();
    final senderStudent = allStudents.firstWhere(
      (s) => s.id == request.senderId,
      orElse: () => StudentProfile(
        id: request.senderId,
        name: 'Peer Student',
        department: 'Software Engineering',
        semester: 7,
        skills: [],
        interests: [],
        projectType: 'Final Year Project',
        availability: 'Flexible',
        bio: '',
      ),
    );

    await _ref.read(teamProvider.notifier).addMemberWithAutoRole(senderStudent);
  }

  Future<void> rejectRequest(String requestId) async {
    final currentRequests = List<TeamRequest>.from(state.requests);
    final index = currentRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    currentRequests[index] = currentRequests[index].copyWith(
      status: 'rejected',
    );
    await LocalStore.saveRequests(currentRequests);
    _updateStateWith(currentRequests);
  }

  Future<void> cancelRequest(String requestId) async {
    final currentRequests = List<TeamRequest>.from(state.requests);
    final index = currentRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    currentRequests[index] = currentRequests[index].copyWith(
      status: 'cancelled',
    );
    await LocalStore.saveRequests(currentRequests);
    _updateStateWith(currentRequests);
  }
}

final requestsProvider = StateNotifierProvider<RequestsNotifier, RequestsState>(
  (ref) {
    return RequestsNotifier(ref);
  },
);
