import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/team_request.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/local_storage/local_store.dart';
import '../providers/requests_provider.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsProvider);
    final received = requestsState.receivedRequests;
    final sent = requestsState.sentRequests;
    final pendingCount = requestsState.pendingIncomingCount;

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
                Icons.mail_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Team Invitations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryIndigo,
          unselectedLabelColor: AppColors.secondarySlate,
          indicatorColor: AppColors.primaryIndigo,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Received'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$pendingCount',
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
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sent'),
                  const SizedBox(width: 6),
                  Text(
                    '(${sent.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Received Tab
          _buildReceivedTab(received),
          // Sent Tab
          _buildSentTab(sent),
        ],
      ),
    );
  }

  Widget _buildReceivedTab(List<TeamRequest> requests) {
    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_rounded,
        title: 'No Incoming Requests',
        message:
            'You have no incoming invitations yet. Explore student profiles to discover peers and send requests.',
      );
    }

    final allStudents = LocalStore.getStudents();

    return ListView.builder(
      itemCount: requests.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final request = requests[index];
        final sender = allStudents.firstWhere(
          (s) => s.id == request.senderId,
          orElse: () => StudentProfile(
            id: request.senderId,
            name: 'Fellow Student',
            department: 'Computer Science',
            semester: 7,
            skills: [],
            interests: [],
            projectType: 'Final Year Project',
            availability: 'Flexible',
            bio: '',
          ),
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Info & Status Badge
                Row(
                  children: [
                    AvatarWidget(
                      avatarKey: sender.avatar,
                      name: sender.name,
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sender.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${sender.department} • Sem ${sender.semester}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      status: request.isExpired ? 'expired' : request.status,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Invitation message bubble
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slateLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    request.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Timestamp & Expiry Indicator (FR-4.7)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(request.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (request.isPending)
                      Row(
                        children: [
                          Icon(
                            request.isExpired
                                ? Icons.timer_off_outlined
                                : Icons.timer_outlined,
                            size: 13,
                            color: request.isExpired
                                ? AppColors.statusRejected
                                : AppColors.statusPending,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.expiryStatusText,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: request.isExpired
                                  ? AppColors.statusRejected
                                  : AppColors.statusPending,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Action Buttons for Pending Requests (FR-4.3)
                if (request.isPending && !request.isExpired) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Reject Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.statusRejected,
                            side: const BorderSide(
                              color: AppColors.statusRejected,
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _handleReject(request, sender.name),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Accept Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentEmerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _handleAccept(request, sender.name),
                          child: const Text('Accept & Add'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSentTab(List<TeamRequest> requests) {
    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.send_rounded,
        title: 'No Sent Requests',
        message:
            'You have not sent any team invitations yet. Browse Discover or Best Matches to invite students to your project.',
      );
    }

    final allStudents = LocalStore.getStudents();

    return ListView.builder(
      itemCount: requests.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final request = requests[index];
        final receiver = allStudents.firstWhere(
          (s) => s.id == request.receiverId,
          orElse: () => StudentProfile(
            id: request.receiverId,
            name: 'Candidate',
            department: 'Computer Science',
            semester: 7,
            skills: [],
            interests: [],
            projectType: 'Final Year Project',
            availability: 'Flexible',
            bio: '',
          ),
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarWidget(
                      avatarKey: receiver.avatar,
                      name: receiver.name,
                      radius: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To: ${receiver.name}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${receiver.department} • Sem ${receiver.semester}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      status: request.isExpired ? 'expired' : request.status,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  request.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sent: ${DateFormat('MMM d, h:mm a').format(request.createdAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (request.isPending)
                      Text(
                        request.expiryStatusText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                  ],
                ),
                // Cancel Request Option
                if (request.isPending) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondarySlate,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _handleCancel(request, receiver.name),
                      child: const Text('Cancel Request'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAccept(TeamRequest request, String name) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Accept Team Request',
      message:
          'Accepting $name will automatically add them to your team roster and assign them to the most suitable open role.',
      confirmText: 'Accept & Add to Team',
    );

    if (confirmed && mounted) {
      await ref.read(requestsProvider.notifier).acceptRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.accentEmerald,
            content: Text('$name accepted and added to your project team!'),
          ),
        );
      }
    }
  }

  Future<void> _handleReject(TeamRequest request, String name) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Reject Request',
      message: 'Are you sure you want to decline the invitation from $name?',
      confirmText: 'Decline Invitation',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(requestsProvider.notifier).rejectRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Declined request from $name.')));
      }
    }
  }

  Future<void> _handleCancel(TeamRequest request, String name) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancel Request',
      message: 'Are you sure you want to withdraw your invitation to $name?',
      confirmText: 'Withdraw Invitation',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(requestsProvider.notifier).cancelRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancelled invitation to $name.')),
        );
      }
    }
  }
}
