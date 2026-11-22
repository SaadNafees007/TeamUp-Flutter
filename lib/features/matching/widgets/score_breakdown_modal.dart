import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/student_profile.dart';
import '../../../data/models/match_breakdown.dart';

class ScoreBreakdownModal extends StatelessWidget {
  final StudentProfile candidate;
  final MatchBreakdown breakdown;

  const ScoreBreakdownModal({
    super.key,
    required this.candidate,
    required this.breakdown,
  });

  static void show(
    BuildContext context,
    StudentProfile candidate,
    MatchBreakdown breakdown,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          ScoreBreakdownModal(candidate: candidate, breakdown: breakdown),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Drag handle
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

            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Match Transparency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Evaluation for ${candidate.name}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigoLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${breakdown.finalScore}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryIndigo,
                        ),
                      ),
                      Text(
                        breakdown.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryIndigoDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            // Official Formula Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slateLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Formula: S = (0.40 × Skills) + (0.25 × Interests) + (0.20 × ProjectType) + (0.15 × Avail & Semester)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateDark,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 1. Skills Category (40%)
            _buildScoreRow(
              title: 'Skills Match (40% Weight)',
              subscore: breakdown.skillsScore,
              weight: 0.40,
              weightedScore: breakdown.skillsWeighted,
              details: breakdown.matchingSkills.isNotEmpty
                  ? 'Matched: ${breakdown.matchingSkills.join(", ")}'
                  : 'No open role skill overlap found',
              color: AppColors.primaryIndigo,
            ),

            const SizedBox(height: 12),

            // 2. Interests Category (25%)
            _buildScoreRow(
              title: 'Shared Interests (25% Weight - Jaccard Index)',
              subscore: breakdown.interestsScore,
              weight: 0.25,
              weightedScore: breakdown.interestsWeighted,
              details: candidate.interests.join(", "),
              color: const Color(0xFF0284C7),
            ),

            const SizedBox(height: 12),

            // 3. Project Type Category (20%)
            _buildScoreRow(
              title: 'Project Scope Compatibility (20% Weight)',
              subscore: breakdown.projectTypeScore,
              weight: 0.20,
              weightedScore: breakdown.projectTypeWeighted,
              details: 'Candidate targets: ${candidate.projectType}',
              color: AppColors.accentEmerald,
            ),

            const SizedBox(height: 12),

            // 4. Availability & Semester Category (15%)
            _buildScoreRow(
              title: 'Availability & Semester Proximity (15% Weight)',
              subscore: breakdown.availabilitySemesterScore,
              weight: 0.15,
              weightedScore: breakdown.availabilitySemesterWeighted,
              details: 'Sem ${candidate.semester} • ${candidate.availability}',
              color: AppColors.statusPending,
            ),

            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            // Explainable Reasons Section
            const Text(
              'Generated Match Factors',
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
              children: breakdown.matchReasons.map((reason) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigoLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: AppColors.primaryIndigo,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryIndigoDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (breakdown.bridgesSkillGap) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentEmerald.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.accentEmerald,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Skill Gap Solution: This candidate bridges one or more critical missing skills in your team roles!',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow({
    required String title,
    required double subscore,
    required double weight,
    required double weightedScore,
    required String details,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${subscore.toStringAsFixed(1)} × $weight = ${weightedScore.toStringAsFixed(1)} pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: subscore / 100.0,
              backgroundColor: AppColors.slateLight,
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            details,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.secondarySlate,
            ),
          ),
        ],
      ),
    );
  }
}
