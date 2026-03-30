import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/decision_option.dart';
import '../../config/constants.dart';
import 'openrouter_service.dart';

/// The Vicharane Engine — brain of the decision tree chatbot.
///
/// HOW IT WORKS:
/// 1. User provides their social enterprise idea
/// 2. Engine constructs a system prompt that tells the AI to:
///    - Act as "Vicharane", a wise social entrepreneurship advisor
///    - Dynamically decide which aspect to explore next
///    - Present analysis + 3-4 decision options as structured JSON
///    - Track which aspects have been covered
///    - Generate a final roadmap when all aspects are explored
/// 3. At each step, the AI adapts based on ALL previous decisions
/// 4. The engine parses the AI's structured response into UI-friendly data
///
/// KEY DESIGN DECISION (Dynamic vs Fixed Tree):
/// We use a DYNAMIC approach — the AI decides the flow based on the idea.
/// A farming education app gets different questions than a health fintech.
/// But we ensure ALL core aspects get covered via the system prompt checklist.
class VicharaneEngine extends ChangeNotifier {
  final OpenRouterService _apiService;

  // ── State ─────────────────────────────────────────
  final List<ChatMessage> _messages = [];
  List<DecisionOption> _currentOptions = [];
  String _currentAnalysis = '';
  String _currentQuestion = '';
  String? _currentPhaseLabel;
  final List<String> _coveredAspects = [];
  bool _isLoading = false;
  bool _isComplete = false;
  String? _errorMessage;
  String _userIdea = '';

  // ── Getters ───────────────────────────────────────
  List<ChatMessage> get messages =>
      _messages.where((m) => m.type != MessageType.system).toList();
  List<ChatMessage> get allMessages => List.unmodifiable(_messages);
  List<DecisionOption> get currentOptions =>
      List.unmodifiable(_currentOptions);
  String get currentAnalysis => _currentAnalysis;
  String get currentQuestion => _currentQuestion;
  String? get currentPhaseLabel => _currentPhaseLabel;
  List<String> get coveredAspects => List.unmodifiable(_coveredAspects);
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  String? get errorMessage => _errorMessage;
  String get userIdea => _userIdea;

  /// Progress as a fraction (0.0 to 1.0)
  double get progress {
    if (AppConstants.coreAspects.isEmpty) return 0;
    return _coveredAspects.length / AppConstants.coreAspects.length;
  }

  VicharaneEngine({OpenRouterService? apiService})
      : _apiService = apiService ?? OpenRouterService();

  // ── Public API ────────────────────────────────────

  /// Start a new decision tree session with the user's idea.
  Future<void> startSession(String idea) async {
    _userIdea = idea.trim();
    _messages.clear();
    _currentOptions.clear();
    _coveredAspects.clear();
    _isComplete = false;
    _errorMessage = null;

    // Add the system prompt (hidden from UI, sent to AI)
    _messages.add(ChatMessage.system(_buildSystemPrompt()));

    // Add the user's idea as the first user message
    _messages.add(ChatMessage.user(
      'My social enterprise idea: $_userIdea',
      metadata: {'type': 'idea_input'},
    ));

    notifyListeners();

    // Get the AI's first response
    await _getAiResponse();
  }

  /// User selected one of the decision option cards.
  Future<void> selectOption(DecisionOption option) async {
    if (_isLoading) return;

    // Add user's choice as a message
    _messages.add(ChatMessage.user(
      option.title,
      metadata: {
        'type': 'option_selected',
        'option': option.toJson(),
      },
    ));

    _currentOptions.clear();
    notifyListeners();

    await _getAiResponse();
  }

  /// User typed a custom response instead of picking an option.
  Future<void> sendCustomResponse(String text) async {
    if (_isLoading || text.trim().isEmpty) return;

    _messages.add(ChatMessage.user(
      text.trim(),
      metadata: {'type': 'custom_response'},
    ));

    _currentOptions.clear();
    notifyListeners();

    await _getAiResponse();
  }

  /// Reset everything for a new session.
  void reset() {
    _messages.clear();
    _currentOptions.clear();
    _coveredAspects.clear();
    _currentAnalysis = '';
    _currentQuestion = '';
    _currentPhaseLabel = null;
    _isComplete = false;
    _isLoading = false;
    _errorMessage = null;
    _userIdea = '';
    notifyListeners();
  }

  // ── Private Methods ───────────────────────────────

  /// Call the AI and process its response.
  Future<void> _getAiResponse() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert our messages to the API format
      final apiMessages = _messages.map((m) => m.toApiFormat()).toList();

      // Call OpenRouter
      final responseText = await _apiService.sendMessage(apiMessages);

      // Try to parse structured JSON from the response
      final parsed = _parseAiResponse(responseText);

      if (parsed != null) {
        _currentAnalysis = parsed['analysis'] ?? '';
        _currentQuestion = parsed['question'] ?? '';
        _currentPhaseLabel = parsed['phase_label'];

        // Track covered aspects
        if (parsed['covered_aspect'] != null) {
          final aspect = parsed['covered_aspect'] as String;
          if (!_coveredAspects.contains(aspect)) {
            _coveredAspects.add(aspect);
          }
        }

        // Check if the journey is complete
        if (parsed['is_complete'] == true) {
          _isComplete = true;
          _currentOptions.clear();

          // The AI's final message is the summary/roadmap
          _messages.add(ChatMessage.ai(
            responseText,
            metadata: {'type': 'summary', 'parsed': parsed},
          ));
        } else {
          // Parse decision options
          final optionsList = parsed['options'] as List<dynamic>?;
          if (optionsList != null) {
            _currentOptions = optionsList
                .map((o) =>
                    DecisionOption.fromJson(o as Map<String, dynamic>))
                .toList();
          }

          // Build display text: analysis + question
          final displayText = StringBuffer();
          if (_currentAnalysis.isNotEmpty) {
            displayText.writeln(_currentAnalysis);
          }
          if (_currentQuestion.isNotEmpty) {
            displayText.writeln();
            displayText.write('**$_currentQuestion**');
          }

          _messages.add(ChatMessage.ai(
            displayText.toString().trim(),
            metadata: {'type': 'decision_point', 'parsed': parsed},
          ));
        }
      } else {
        // Couldn't parse structured JSON — show raw response
        _messages.add(ChatMessage.ai(
          responseText,
          metadata: {'type': 'raw_response'},
        ));
        _currentOptions.clear();
      }
    } on OpenRouterException catch (e) {
      _errorMessage = e.message;
      _messages.add(ChatMessage.ai(
        '⚠️ Something went wrong. Please try again.\n\n_${e.message}_',
        metadata: {'type': 'error'},
      ));
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Vicharane Engine Error: $e');
      _messages.add(ChatMessage.ai(
        '⚠️ An unexpected error occurred. Please try again.\n\nError: ${e.toString()}',
        metadata: {'type': 'error'},
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Parse the AI's response to extract structured data.
  ///
  /// The AI is prompted to return JSON wrapped in ```json ... ```
  /// We extract that JSON and parse it.
  Map<String, dynamic>? _parseAiResponse(String response) {
    try {
      // Try to find JSON block in markdown code fence
      final jsonMatch = RegExp(
        r'```json\s*([\s\S]*?)\s*```',
        multiLine: true,
      ).firstMatch(response);

      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(1)!.trim();
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }

      // Try to parse the entire response as JSON
      if (response.trimLeft().startsWith('{')) {
        return jsonDecode(response.trim()) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      debugPrint('Failed to parse AI response: $e');
      return null;
    }
  }

  /// Build the system prompt that makes the AI behave as Vicharane.
  ///
  /// THIS IS THE MOST IMPORTANT PART OF THE APP.
  /// The quality of this prompt directly determines the quality
  /// of the user experience.
  String _buildSystemPrompt() {
    final coveredList = _coveredAspects.isEmpty
        ? 'None yet'
        : _coveredAspects.join(', ');

    return '''
You are **Vicharane** (विचारणे) — a wise, experienced social entrepreneurship advisor. Your name means "thoughtful analysis" in Sanskrit.

Your role: Guide a young aspiring social entrepreneur through critical decisions about their idea, one step at a time. You are NOT giving a report — you are having a conversation where each response presents ONE decision point.

## YOUR BEHAVIOR:
1. At each step, briefly analyze the current situation (2-3 sentences max)
2. Then ask ONE focused question with 3-4 concrete options
3. ADAPT your questions based on the user's previous choices
4. Cover ALL core aspects naturally through the conversation flow
5. Be encouraging but realistic — flag genuine risks honestly
6. Use real-world examples when relevant (Grameen Bank, SELCO, Aravind Eye Care, etc.)
7. The user may also type their own custom response instead of picking an option — handle that gracefully

## CORE ASPECTS TO COVER (check them off as you go):
${AppConstants.coreAspects.map((a) => '- $a').join('\n')}

## ALREADY COVERED:
$coveredList

## RESPONSE FORMAT:
You MUST respond with a JSON block wrapped in ```json ... ``` markers. The JSON must have this structure:

```json
{
  "phase_label": "Short label for current decision area",
  "covered_aspect": "Which core aspect this step covers (exact string from the list above)",
  "analysis": "Your 2-3 sentence analysis/insight about the current situation. Use real examples. Be specific to their idea.",
  "question": "Your focused question for this decision point",
  "options": [
    {"id": "opt1", "title": "Short Title", "description": "1-2 sentence description of this choice", "icon": "icon_name"},
    {"id": "opt2", "title": "Short Title", "description": "1-2 sentence description of this choice", "icon": "icon_name"},
    {"id": "opt3", "title": "Short Title", "description": "1-2 sentence description of this choice", "icon": "icon_name"}
  ],
  "is_complete": false
}
```

## AVAILABLE ICON NAMES:
lightbulb, people, school, phone, location, money, health, rocket, shield, chart, globe, handshake, building, elderly, volunteer, agriculture, water, education, tech, community, government, timeline, warning, budget, target, expand, hybrid, scale, strategy

## WHEN ALL ASPECTS ARE COVERED:
Set "is_complete": true and replace "options" with a "summary" field containing a structured roadmap:

```json
{
  "phase_label": "Your Complete Roadmap",
  "covered_aspect": "Roadmap & Execution Plan",
  "analysis": "Comprehensive summary of all decisions made and their implications...",
  "question": "",
  "options": [],
  "is_complete": true,
  "summary": {
    "idea": "Restated idea",
    "decisions": [
      {"aspect": "Target Audience", "choice": "What they chose", "insight": "Why this matters"}
    ],
    "next_steps": ["Step 1...", "Step 2...", "Step 3..."],
    "risks_to_watch": ["Risk 1...", "Risk 2..."],
    "estimated_timeline": "X months",
    "key_advice": "One powerful closing piece of advice"
  }
}
```

## IMPORTANT RULES:
- NEVER dump all aspects at once. ONE decision per response
- Dynamic order: let the idea dictate which aspect comes first
- If the user gives a custom response, integrate it naturally
- Keep analysis SHORT and ACTIONABLE
- Options should represent genuinely different strategic paths
- Each option should teach something about real social entrepreneurship
''';
  }

  /// Dispose the API service when the engine is disposed
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
