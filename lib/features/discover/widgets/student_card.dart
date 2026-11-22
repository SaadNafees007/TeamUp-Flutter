import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../data/models/student_profile.dart';
import '../../matching/providers/matching_provider.dart';
import '../../requests/widgets/send_request_dialog.dart';
import 'student_details_modal.dart';
import '../../matching/widgets/score_breakdown_modal.dart';

class StudentCard extends ConsumerWidget {
  final StudentProfile student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(candidateMatchProvider(student));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          StudentDetailsModal.show(context, student);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name, Dept, Semester & Match Score Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarWidget(
                    avatarKey: student.avatar,
                    name: student.name,
                    radius: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.department} • Sem ${student.semester}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Match Score Pill
                  InkWell(
                    onTap: () {
                      ScoreBreakdownModal.show(context, student, breakdown);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(
                          breakdown.finalScore,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getScoreColor(
                            breakdown.finalScore,
                          ).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 15,
                            color: _getScoreColor(breakdown.finalScore),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${breakdown.finalScore}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _getScoreColor(breakdown.finalScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bio
              Text(
                student.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 10),

              // Skills Wrap
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: student.skills.take(4).map((skill) {
                  final isMatching = breakdown.matchingSkills.any(
                    (m) => m.toLowerCase() == skill.toLowerCase(),
                  );
                  return SkillChip(skill: skill, isHighlighted: isMatching);
                }).toList(),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // Bottom Row: Availability & Send Request Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Availability Indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentEmerald,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        student.availability,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                  // Send Request Button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      SendRequestDialog.show(context, student);
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 14,
                      color: AppColors.primaryIndigo,
                    ),
                    label: const Text(
                      'Send Request',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.accentEmerald;
    if (score >= 65) return AppColors.primaryIndigo;
    if (score >= 45) return AppColors.statusPending;
    return AppColors.secondarySlate;
  }
}
