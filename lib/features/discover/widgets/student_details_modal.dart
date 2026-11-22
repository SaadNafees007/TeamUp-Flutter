import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../data/models/student_profile.dart';
import '../../matching/providers/matching_provider.dart';
import '../../matching/widgets/score_breakdown_modal.dart';
import '../../requests/widgets/send_request_dialog.dart';

class StudentDetailsModal extends ConsumerWidget {
  final StudentProfile student;

  const StudentDetailsModal({super.key, required this.student});

  static void show(BuildContext context, StudentProfile student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StudentDetailsModal(student: student),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(candidateMatchProvider(student));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),

            // Profile Header
            Row(
              children: [
                AvatarWidget(
                  avatarKey: student.avatar,
                  name: student.name,
                  radius: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${student.department} • Semester ${student.semester}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.slateLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          student.projectType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slateDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Match Score Card with Breakdown Action
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                ScoreBreakdownModal.show(context, student, breakdown);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigoLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryIndigo,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${breakdown.finalScore}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Match: ${breakdown.label}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryIndigoDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            breakdown.matchReasons.isNotEmpty
                                ? breakdown.matchReasons.first
                                : 'Calculated by Smart Match Engine',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.primaryIndigo,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // About / Bio
            const Text(
              'About & Bio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              student.bio,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 16),

            // Availability
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.secondarySlate,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Availability: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  student.availability,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Technical Skills
            const Text(
              'Technical Skills',
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
              children: student.skills.map((skill) {
                final isMatching = breakdown.matchingSkills.any(
                  (m) => m.toLowerCase() == skill.toLowerCase(),
                );
                return SkillChip(skill: skill, isHighlighted: isMatching);
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Areas of Interest
            const Text(
              'Areas of Interest',
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
              children: student.interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slateLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slateDark,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      SendRequestDialog.show(context, student);
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
