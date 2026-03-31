import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../shared/widgets/gradient_button.dart';

/// Idea Input screen — where the user describes their social enterprise idea.
///
/// FLOW:
/// 1. User sees an inspiring prompt
/// 2. Types their idea in a text field
/// 3. Taps "Begin Journey" → navigates to chat screen
///
/// DESIGN:
/// - Clean, focused, single-purpose screen
/// - Placeholder examples to reduce blank-page anxiety
/// - Character count to encourage concise ideas
class IdeaInputScreen extends StatefulWidget {
  const IdeaInputScreen({super.key});

  @override
  State<IdeaInputScreen> createState() => _IdeaInputScreenState();
}

class _IdeaInputScreenState extends State<IdeaInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startJourney() {
    final idea = _controller.text.trim();
    if (idea.isEmpty) return;

    Navigator.of(context).pushReplacementNamed(
      '/chat',
      arguments: idea,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.backgroundLightMode,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Header ──
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small brand tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            color: AppColors.primaryLight,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ImpactForge Engine',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'What social problem\ndo you want to solve?',
                      style: AppTypography.heading1.copyWith(
                        fontSize: 28,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                          Text(
                            'ImpactForge Engine',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Text Input ──
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 600),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.glassBorder : Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 5,
                    maxLength: 500,
                    style: AppTypography.body.copyWith(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText:
                          'e.g., "A mobile platform that connects rural artisans '
                          'directly with urban buyers, cutting out middlemen and '
                          'ensuring fair wages..."',
                      hintMaxLines: 4,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterStyle: AppTypography.label,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Example Ideas (inspiration) ──
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEED INSPIRATION?',
                      style: AppTypography.label.copyWith(
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ExampleChip(
                      text: '📚 Digital literacy program for rural women',
                      onTap: () => _controller.text =
                          'A digital literacy program that teaches rural women basic '
                          'smartphone and internet skills so they can access government '
                          'schemes, healthcare info, and financial services.',
                    ),
                    const SizedBox(height: 8),
                    _ExampleChip(
                      text: '♻️ Waste-to-product enterprise for slum youth',
                      onTap: () => _controller.text =
                          'A social enterprise that employs slum youth to collect, '
                          'sort, and upcycle urban waste into sellable products like '
                          'bags, furniture, and construction materials.',
                    ),
                    const SizedBox(height: 8),
                    _ExampleChip(
                      text: '🏥 Affordable telemedicine for tier-3 towns',
                      onTap: () => _controller.text =
                          'A telemedicine platform connecting patients in tier-3 '
                          'towns with specialist doctors in cities, using local '
                          'pharmacy shops as video consultation hubs.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── CTA Button ──
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 600),
                child: GradientButton(
                  text: 'Begin Your Journey',
                  icon: Icons.rocket_launch_outlined,
                  onPressed: _hasText ? _startJourney : null,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable example idea chip — fills the text field with a sample idea.
class _ExampleChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.glassBorder : Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}
