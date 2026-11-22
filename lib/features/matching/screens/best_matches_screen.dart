import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/skill_chip.dart';
import '../providers/matching_provider.dart';
import '../widgets/score_breakdown_modal.dart';
import '../../requests/widgets/send_request_dialog.dart';
import '../../discover/widgets/student_details_modal.dart';

class BestMatchesScreen extends ConsumerWidget {
  const BestMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(bestMatchesProvider);

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
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Matches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Ranked by Smart Match Engine',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // FR-3.4 Scoring Transparency Dialog Button
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryIndigo,
            ),
            tooltip: 'Formula & Weighting Explanation',
            onPressed: () {
              _showFormulaInfoDialog(context);
            },
          ),
        ],
      ),
      body: matches.isEmpty
          ? const Center(child: Text('No match candidates available.'))
          : ListView.builder(
              itemCount: matches.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = matches[index];
                final candidate = item.student;
                final breakdown = item.breakdown;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: index == 0
                          ? AppColors.primaryIndigo.withValues(alpha: 0.5)
                          : AppColors.border,
                      width: index == 0 ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      StudentDetailsModal.show(context, candidate);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Rank Badge, Avatar, Name & Score
                          Row(
                            children: [
                              // Rank number
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? AppColors.primaryIndigo
                                      : AppColors.slateLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: index == 0
                                          ? Colors.white
                                          : AppColors.slateDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AvatarWidget(
                                avatarKey: candidate.avatar,
                                name: candidate.name,
                                radius: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Text(
                                      '${candidate.department} • Sem ${candidate.semester}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Score Badge (Clickable for breakdown)
                              InkWell(
                                onTap: () {
                                  ScoreBreakdownModal.show(
                                    context,
                                    candidate,
                                    breakdown,
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getLabelColor(
                                      breakdown.label,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getLabelColor(
                                        breakdown.label,
                                      ).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${breakdown.finalScore}%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: _getLabelColor(
                                            breakdown.label,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        breakdown.label,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: _getLabelColor(
                                            breakdown.label,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Match Reasons Chips (FR-3.3 Explainable Match Reasons)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: breakdown.matchReasons.take(3).map((
                              reason,
                            ) {
                              final isSkillGap = reason.contains('skill gap');
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSkillGap
                                      ? AppColors.emeraldLight
                                      : AppColors.primaryIndigoLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSkillGap
                                          ? Icons.stars_rounded
                                          : Icons.check_circle_rounded,
                                      size: 12,
                                      color: isSkillGap
                                          ? AppColors.accentEmerald
                                          : AppColors.primaryIndigo,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSkillGap
                                            ? const Color(0xFF065F46)
                                            : AppColors.primaryIndigoDark,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 10),

                          // Skills chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: candidate.skills.take(4).map((skill) {
                              final isMatching = breakdown.matchingSkills.any(
                                (m) => m.toLowerCase() == skill.toLowerCase(),
                              );
                              return SkillChip(
                                skill: skill,
                                isHighlighted: isMatching,
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),

                          // Card Bottom Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  ScoreBreakdownModal.show(
                                    context,
                                    candidate,
                                    breakdown,
                                  );
                                },
                                icon: const Icon(
                                  Icons.analytics_outlined,
                                  size: 15,
                                  color: AppColors.secondarySlate,
                                ),
                                label: const Text(
                                  'Score Breakdown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  SendRequestDialog.show(context, candidate);
                                },
                                icon: const Icon(Icons.send_rounded, size: 14),
                                label: const Text(
                                  'Send Request',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
              },
            ),
    );
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case 'Excellent Match':
        return AppColors.accentEmerald;
      case 'Strong Match':
        return AppColors.primaryIndigo;
      case 'Good Match':
        return AppColors.statusPending;
      default:
        return AppColors.secondarySlate;
    }
  }

  void _showFormulaInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.calculate_rounded, color: AppColors.primaryIndigo),
            SizedBox(width: 10),
            Text(
              'Smart Match Engine',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The VisioSpark Smart Match formula is strictly deterministic and mathematically computed:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              '• Skills Score: 40%',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '  Evaluated against required skills of open team roles.',
              style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
            ),
            SizedBox(height: 6),
            Text(
              '• Shared Interests: 25%',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '  Jaccard Similarity Index = (Intersection / Union) × 100.',
              style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
            ),
            SizedBox(height: 6),
            Text(
              '• Project Type: 20%',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '  Full match (100%) for compatible scopes, 0% for conflict.',
              style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
            ),
            SizedBox(height: 6),
            Text(
              '• Availability & Semester: 15%',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '  Semester proximity decay + schedule availability overlap.',
              style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
