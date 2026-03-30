import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../core/models/chat_message.dart';
import '../../core/services/vicharane_engine.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// Summary screen — displays the final roadmap after completing all decisions.
///
/// DESIGN:
/// - Scrollable card layout showing all decisions and insights
/// - Color-coded sections for different aspects
/// - Final AI-generated roadmap at the top
/// - Option to start with a new idea
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = ModalRoute.of(context)?.settings.arguments as VicharaneEngine?;

    if (engine == null) {
      return Scaffold(
        body: Center(
          child: Text('No data available', style: AppTypography.body),
        ),
      );
    }

    // Get all AI messages with decision data and user responses
    final allMessages = engine.messages;
    final decisions = <Map<String, String>>[];

    // Extract decision pairs (AI question + user answer)
    for (int i = 0; i < allMessages.length; i++) {
      final msg = allMessages[i];
      if (msg.type == MessageType.user && msg.metadata?['type'] != 'idea_input') {
        // Find the preceding AI message for context
        String aspect = '';
        if (i > 0 && allMessages[i - 1].type == MessageType.ai) {
          final aiMeta = allMessages[i - 1].metadata;
          if (aiMeta?['parsed'] != null) {
            aspect = (aiMeta!['parsed'] as Map)['phase_label'] ?? '';
          }
        }
        decisions.add({
          'aspect': aspect,
          'choice': msg.content,
        });
      }
    }

    // Get the final AI summary message
    final summaryMessages = allMessages.where(
      (m) => m.type == MessageType.ai && m.metadata?['type'] == 'summary',
    );
    final summaryMessage = summaryMessages.isNotEmpty
        ? summaryMessages.last
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Roadmap', style: AppTypography.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Idea Recap ──
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text('Your Idea',
                          style: AppTypography.label.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(engine.userIdea, style: AppTypography.body),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Decisions Made ──
            Text(
              'DECISIONS MADE',
              style: AppTypography.label.copyWith(
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(decisions.length, (i) {
              final decision = decisions[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DecisionTile(
                  index: i + 1,
                  aspect: decision['aspect'] ?? 'Decision',
                  choice: decision['choice'] ?? '',
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── AI Summary / Roadmap ──
            if (summaryMessage != null) ...[
              Text(
                'AI-GENERATED ROADMAP',
                style: AppTypography.label.copyWith(
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                child: MarkdownBody(
                  data: _extractSummaryText(summaryMessage),
                  styleSheet: MarkdownStyleSheet(
                    p: AppTypography.body,
                    strong: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentLight,
                    ),
                    h1: AppTypography.heading2,
                    h2: AppTypography.heading3,
                    h3: AppTypography.heading3.copyWith(fontSize: 16),
                    listBullet: AppTypography.body,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── CTA ──
            GradientButton(
              text: 'Start a New Idea',
              icon: Icons.add_circle_outline,
              gradient: AppColors.accentGradient,
              onPressed: () {
                engine.reset();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/idea-input',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Extract readable text from the summary message.
  String _extractSummaryText(ChatMessage message) {
    final parsed = message.metadata?['parsed'] as Map<String, dynamic>?;
    if (parsed == null) return message.content;

    final summary = parsed['summary'] as Map<String, dynamic>?;
    if (summary == null) return parsed['analysis'] ?? message.content;

    final buffer = StringBuffer();

    if (summary['idea'] != null) {
      buffer.writeln('### 💡 Idea');
      buffer.writeln(summary['idea']);
      buffer.writeln();
    }

    if (summary['decisions'] != null) {
      buffer.writeln('### 🎯 Key Decisions');
      for (final d in summary['decisions']) {
        buffer.writeln('- **${d['aspect']}**: ${d['choice']}');
        if (d['insight'] != null) {
          buffer.writeln('  _${d['insight']}_');
        }
      }
      buffer.writeln();
    }

    if (summary['next_steps'] != null) {
      buffer.writeln('### 🚀 Next Steps');
      for (final step in summary['next_steps']) {
        buffer.writeln('1. $step');
      }
      buffer.writeln();
    }

    if (summary['risks_to_watch'] != null) {
      buffer.writeln('### ⚠️ Risks to Watch');
      for (final risk in summary['risks_to_watch']) {
        buffer.writeln('- $risk');
      }
      buffer.writeln();
    }

    if (summary['estimated_timeline'] != null) {
      buffer.writeln('### 📅 Estimated Timeline');
      buffer.writeln(summary['estimated_timeline']);
      buffer.writeln();
    }

    if (summary['key_advice'] != null) {
      buffer.writeln('### 🧠 Key Advice');
      buffer.writeln('> ${summary['key_advice']}');
    }

    return buffer.toString();
  }
}

/// Individual decision tile showing the aspect and what the user chose.
class _DecisionTile extends StatelessWidget {
  final int index;
  final String aspect;
  final String choice;

  const _DecisionTile({
    required this.index,
    required this.aspect,
    required this.choice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Number Badge ──
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (aspect.isNotEmpty)
                  Text(
                    aspect,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(choice, style: AppTypography.body.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
