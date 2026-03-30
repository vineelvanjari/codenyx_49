import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../config/constants.dart';
import '../../core/models/chat_message.dart';
import '../../core/services/vicharane_engine.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/user_choice_bubble.dart';
import 'widgets/decision_cards.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/phase_progress.dart';

/// Chat screen — the main decision tree conversation experience.
///
/// ARCHITECTURE:
/// - Listens to VicharaneEngine (ChangeNotifier) for state updates
/// - Renders messages as a scrollable list
/// - Shows decision cards or text input at the bottom
/// - Progress bar at the top tracks covered aspects
///
/// KEY UX DECISIONS:
/// 1. Auto-scroll to bottom on new messages
/// 2. Both option cards AND free text input available
/// 3. Text input stays visible even when options are shown
/// 4. When journey completes → shows "View Summary" button
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late VicharaneEngine _engine;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _engine = VicharaneEngine();
    _engine.addListener(_onEngineUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Get the idea from navigation arguments
      final idea = ModalRoute.of(context)?.settings.arguments as String?;
      if (idea != null && idea.isNotEmpty) {
        _engine.startSession(idea);
      }
    }
  }

  void _onEngineUpdate() {
    if (mounted) {
      setState(() {});
      // Auto-scroll to bottom after a short delay (let widgets render first)
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _sendCustomMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _engine.isLoading) return;

    _textController.clear();
    _textFocusNode.unfocus();
    _engine.sendCustomResponse(text);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── App Bar ──
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 22),
            tooltip: 'Start over',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceLight,
                  title: Text('Start Over?', style: AppTypography.heading3),
                  content: Text(
                    'This will clear your current conversation and decisions.',
                    style: AppTypography.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _engine.reset();
                        Navigator.of(context).pushReplacementNamed(
                          '/idea-input',
                        );
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Progress Bar ──
          if (_engine.coveredAspects.isNotEmpty || _engine.currentPhaseLabel != null)
            PhaseProgress(
              progress: _engine.progress,
              phaseLabel: _engine.currentPhaseLabel,
              coveredCount: _engine.coveredAspects.length,
              totalCount: AppConstants.coreAspects.length,
            ),

          // ── Chat Messages ──
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _engine.messages.length +
                  (_engine.isLoading ? 1 : 0) +
                  (_engine.currentOptions.isNotEmpty ? 1 : 0) +
                  (_engine.isComplete ? 1 : 0),
              itemBuilder: (context, index) {
                final messages = _engine.messages;

                // ── Render chat messages ──
                if (index < messages.length) {
                  final message = messages[index];
                  if (message.type == MessageType.ai) {
                    return AiMessageBubble(
                      content: message.content,
                      animate: index == messages.length - 1,
                    );
                  } else {
                    return UserChoiceBubble(
                      content: message.content,
                      animate: index == messages.length - 1,
                    );
                  }
                }

                // ── Loading indicator ──
                if (_engine.isLoading &&
                    index == messages.length) {
                  return const TypingIndicator();
                }

                // Adjust index for items after messages + loading
                final adjustedIndex = index -
                    messages.length -
                    (_engine.isLoading ? 1 : 0);

                // ── Decision cards ──
                if (!_engine.isLoading &&
                    _engine.currentOptions.isNotEmpty &&
                    adjustedIndex == 0) {
                  return DecisionCards(
                    options: _engine.currentOptions,
                    onSelected: (option) => _engine.selectOption(option),
                  );
                }

                // ── Journey complete button ──
                if (_engine.isComplete) {
                  return _buildCompletionCard();
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // ── Text Input Bar ──
          if (!_engine.isComplete) _buildTextInput(),
        ],
      ),
    );
  }

  /// Text input bar at the bottom — always visible for custom responses.
  Widget _buildTextInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: Row(
        children: [
          // ── Text Field ──
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              style: AppTypography.body.copyWith(fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendCustomMessage(),
              decoration: InputDecoration(
                hintText: 'Type your own response...',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Send Button ──
          GestureDetector(
            onTap: _engine.isLoading ? null : _sendCustomMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: _engine.isLoading
                    ? null
                    : AppColors.primaryGradient,
                color: _engine.isLoading
                    ? AppColors.surfaceLighter
                    : null,
                borderRadius: BorderRadius.circular(21),
              ),
              child: Icon(
                Icons.send_rounded,
                color: _engine.isLoading
                    ? AppColors.textMuted
                    : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card shown when the decision tree journey is complete.
  Widget _buildCompletionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.accent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Journey Complete! 🎉',
              style: AppTypography.heading3.copyWith(
                color: AppColors.accentLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve explored all the key aspects of your social enterprise idea.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/summary',
                        arguments: _engine,
                      );
                    },
                    icon: const Icon(Icons.summarize_outlined),
                    label: const Text('View Roadmap'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _engine.reset();
                      Navigator.of(context).pushReplacementNamed(
                        '/idea-input',
                      );
                    },
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('New Idea'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.glassBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
