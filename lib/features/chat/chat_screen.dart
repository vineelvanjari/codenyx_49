import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../config/constants.dart';
import '../../core/models/chat_message.dart';
import '../../core/services/vicharane_engine.dart';
import '../../core/services/demo_session.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/idea_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/user_choice_bubble.dart';
import 'widgets/decision_cards.dart';
import 'widgets/typing_indicator.dart';

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
      final idea = ModalRoute.of(context)?.settings.arguments as String?;
      if (idea != null && idea.isNotEmpty) {
        _engine.startSession(idea);
      }
    }
  }

  void _onEngineUpdate() async {
    if (mounted) {
      setState(() {});
      // Auto-publish if AI triggers complete
      if (_engine.isComplete && _engine.publishData != null) {
        _handleAutoPublish();
      }
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  Future<void> _handleAutoPublish() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = DemoSession.currentUid ?? user?.uid;
      
      if (uid == null) return;
      
      final data = _engine.publishData!;
      
      final ideaModel = IdeaModel(
        id: '', // Firestore auto-generates
        startupUid: uid,
        title: data['title'] ?? 'My Startup Idea',
        description: data['description'] ?? 'No description provided yet.',
        impactScore: data['impact_score'] ?? 50,
        budgetNeeded: (data['budget_needed'] ?? 0).toDouble(),
        status: 'published',
        createdAt: DateTime.now(),
      );

      await FirestoreService().publishIdea(ideaModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Your idea has been automatically published to the Investor Feed!'),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      print('Publish error: $e');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake_outlined),
            tooltip: 'Trigger Bargain Scenario',
            onPressed: () => _engine.triggerBargainScenario(),
          ),
          IconButton(
            icon: const Icon(Icons.publish),
            tooltip: 'Publish Idea',
            onPressed: () => _engine.triggerPublishIdea(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Metrics Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.surfaceLight : Colors.blueGrey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🟢 Budget Remaining', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                    Text('₹${_engine.budgetRemaining.toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade700, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('🔵 Effective Value', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                    Text('${_engine.effectiveValue.toStringAsFixed(0)} pts', style: TextStyle(color: isDark ? Colors.blueAccent : Colors.blue.shade700, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _engine.messages.length + (_engine.isLoading ? 1 : 0) + (_engine.currentOptions.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _engine.messages.length) {
                  final message = _engine.messages[index];
                  if (message.type == MessageType.ai) {
                    return AiMessageBubble(content: message.content, animate: index == _engine.messages.length - 1);
                  } else {
                    return UserChoiceBubble(content: message.content, animate: index == _engine.messages.length - 1);
                  }
                }

                if (_engine.isLoading && index == _engine.messages.length) return const TypingIndicator();

                final adjIndex = index - _engine.messages.length - (_engine.isLoading ? 1 : 0);
                if (!_engine.isLoading && _engine.currentOptions.isNotEmpty && adjIndex == 0) {
                  return DecisionCards(options: _engine.currentOptions, onSelected: _engine.selectOption);
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          if (!_engine.isComplete) _buildTextInput(),
          
          if (_engine.isComplete)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.dashboard),
                label: const Text('Return to Dashboard'),
                onPressed: () => Navigator.pop(context),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? AppColors.glassBorder : Colors.grey.shade300))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendCustomMessage(),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Type your own response...',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2640) : Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_rounded, color: _engine.isLoading ? Colors.grey : AppColors.primary),
            onPressed: _engine.isLoading ? null : _sendCustomMessage,
          ),
        ],
      ),
    );
  }
}
