import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SkillChip extends StatelessWidget {
  final String skill;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const SkillChip({
    super.key,
    required this.skill,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isHighlighted
        ? AppColors.primaryIndigoLight
        : AppColors.slateLight;
    final fg = isHighlighted
        ? AppColors.primaryIndigoDark
        : AppColors.textSecondary;
    final border = isHighlighted
        ? AppColors.primaryIndigo.withValues(alpha: 0.4)
        : AppColors.border;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighlighted) ...[
            const Icon(
              Icons.star_rounded,
              size: 12,
              color: AppColors.primaryIndigo,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            skill,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      );
    }
    return child;
  }
}
