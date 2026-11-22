import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../data/models/student_profile.dart';
import '../providers/requests_provider.dart';

class SendRequestDialog extends ConsumerStatefulWidget {
  final StudentProfile student;

  const SendRequestDialog({super.key, required this.student});

  static Future<void> show(BuildContext context, StudentProfile student) async {
    await showDialog(
      context: context,
      builder: (ctx) => SendRequestDialog(student: student),
    );
  }

  @override
  ConsumerState<SendRequestDialog> createState() => _SendRequestDialogState();
}

class _SendRequestDialogState extends ConsumerState<SendRequestDialog> {
  final TextEditingController _msgController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _msgController.text =
        'Hi ${widget.student.name}! I reviewed your profile and skills in ${widget.student.skills.take(2).join(", ")}. I think you would be a great fit for our team!';
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.all(20),
      title: Row(
        children: [
          AvatarWidget(
            avatarKey: widget.student.avatar,
            name: widget.student.name,
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Team Invitation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'To: ${widget.student.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Invitation Message',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _msgController,
              maxLines: 4,
              maxLength: 350,
              decoration: const InputDecoration(
                hintText:
                    'Explain why you want to collaborate and mention your project...',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Invitation message cannot be blank.';
                }
                if (val.trim().length < 10) {
                  return 'Please write at least 10 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.statusInfo,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Request will expire in 72 hours if unaddressed.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSend,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Request'),
        ),
      ],
    );
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(requestsProvider.notifier)
        .sendRequest(
          receiverId: widget.student.id,
          message: _msgController.text,
        );
    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.accentEmerald,
            content: Text('Invitation sent to ${widget.student.name}!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.statusPending,
            content: Text(
              'You already have an active request to this candidate.',
            ),
          ),
        );
      }
    }
  }
}
