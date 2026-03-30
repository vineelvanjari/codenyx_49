import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';

/// Phase progress bar — shows how far the user is in the decision journey.
///
/// DESIGN:
/// - Thin gradient progress bar at the top
/// - Shows phase label and fraction (e.g., "3/8 aspects covered")
/// - Animates smoothly when progress changes
///
/// WHY THIS MATTERS:
/// Users need to know they're making progress. Without this,
/// the chat feels endless. With it, each decision feels meaningful.
class PhaseProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? phaseLabel;
  final int coveredCount;
  final int totalCount;

  const PhaseProgress({
    super.key,
    required this.progress,
    this.phaseLabel,
    required this.coveredCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (phaseLabel != null)
                Expanded(
                  child: Text(
                    phaseLabel!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                '$coveredCount / $totalCount aspects explored',
                style: AppTypography.label,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Progress Bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
