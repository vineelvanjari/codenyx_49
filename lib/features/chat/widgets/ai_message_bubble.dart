import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animate_do/animate_do.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';

/// AI message bubble — displays Vicharane's analysis/question.
///
/// DESIGN:
/// - Left-aligned, glass-style background
/// - Supports markdown rendering (bold, lists, etc.)
/// - Fades in with animation when appearing
/// - Small "Vicharane" label at the top
class AiMessageBubble extends StatelessWidget {
  final String content;
  final bool animate;

  const AiMessageBubble({
    super.key,
    required this.content,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Padding(
      padding: const EdgeInsets.only(right: 40, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vicharane Label ──
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

          // ── Message Content ──
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
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.chatMessage,
                strong: AppTypography.chatMessage.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
                listBullet: AppTypography.chatMessage,
                h3: AppTypography.heading3.copyWith(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );

    if (animate) {
      return FadeInLeft(
        duration: const Duration(milliseconds: 400),
        child: bubble,
      );
    }

    return bubble;
  }
}
