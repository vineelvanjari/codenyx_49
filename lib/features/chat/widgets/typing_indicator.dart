import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';

/// Typing indicator — shows "Vicharane is thinking..." with shimmer.
///
/// ATOMIC WIDGET — displayed while waiting for the AI response.
/// Uses shimmer effect to feel alive and premium.
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(right: 80, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label ──
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Vicharane', style: AppTypography.label),
                ],
              ),
            ),

            // ── Shimmer Bubble ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Shimmer.fromColors(
                baseColor: AppColors.textMuted,
                highlightColor: AppColors.textSecondary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Dot(),
                    const SizedBox(width: 4),
                    const _Dot(),
                    const SizedBox(width: 4),
                    const _Dot(),
                    const SizedBox(width: 12),
                    Text(
                      'Thinking...',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.textMuted,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
