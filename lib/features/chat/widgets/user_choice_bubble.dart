import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';

/// User choice bubble — displays what the user selected/typed.
///
/// DESIGN:
/// - Right-aligned, primary gradient background
/// - Compact, shows just the choice text
/// - Slides in from right when appearing
class UserChoiceBubble extends StatelessWidget {
  final String content;
  final bool animate;

  const UserChoiceBubble({
    super.key,
    required this.content,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Padding(
      padding: const EdgeInsets.only(left: 60, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── "You" Label ──
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 6),
            child: Text('You', style: AppTypography.label),
          ),

          // ── Message Content ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(
              content,
              style: AppTypography.chatMessage,
            ),
          ),
        ],
      ),
    );

    if (animate) {
      return FadeInRight(
        duration: const Duration(milliseconds: 300),
        child: bubble,
      );
    }

    return bubble;
  }
}
