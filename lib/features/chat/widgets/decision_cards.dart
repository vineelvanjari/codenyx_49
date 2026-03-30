import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';
import '../../../core/models/decision_option.dart';

/// Decision option cards — tappable cards showing the AI's suggested options.
///
/// DESIGN:
/// - Vertically stacked cards (better for mobile)
/// - Each card has icon, title, and description
/// - Border highlights on hover/press
/// - Staggered animation when appearing
///
/// WHY CARDS OVER BUTTONS:
/// Options represent strategic decisions with context.
/// Cards give enough space to explain what each choice means,
/// which is key for the learning experience.
class DecisionCards extends StatelessWidget {
  final List<DecisionOption> options;
  final ValueChanged<DecisionOption> onSelected;

  const DecisionCards({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hint Label ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Choose a path or type your own response below',
              style: AppTypography.label.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // ── Option Cards ──
          ...List.generate(options.length, (index) {
            final option = options[index];
            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: 100 * index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OptionCard(
                  option: option,
                  onTap: () => onSelected(option),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Individual option card — extracted as a separate widget for clarity.
class _OptionCard extends StatefulWidget {
  final DecisionOption option;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed ? AppColors.primary : AppColors.glassBorder,
            width: _isPressed ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Icon ──
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.option.icon,
                color: AppColors.primaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.option.title,
                    style: AppTypography.chatOption,
                  ),
                  if (widget.option.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.option.description,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // ── Arrow ──
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
