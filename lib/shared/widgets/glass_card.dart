import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

/// Glassmorphic card — a semi-transparent card with blur/glow effect.
///
/// ATOMIC WIDGET — provides the signature glass look throughout the app.
/// Used for chat bubbles, decision options, info panels, etc.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
