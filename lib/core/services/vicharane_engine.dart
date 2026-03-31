import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/decision_option.dart';
import '../../config/constants.dart';
import 'openrouter_service.dart';

/// The Vicharane Engine V2 — with 80/20 budget tracking, bargaining, and auto-publishing.
class VicharaneEngine extends ChangeNotifier {
  final OpenRouterService _apiService;

  // ── State ─────────────────────────────────────────
  final List<ChatMessage> _messages = [];
  List<DecisionOption> _currentOptions = [];
  String _currentAnalysis = '';
  String _currentQuestion = '';
  String? _currentPhaseLabel;
  final List<String> _coveredAspects = [];
  
  // ── V2 Metrics ──────────────────────────────────────
  double _budgetRemaining = 500000.0; // Starting virtual budget ₹5,00,000
  double _effectiveValue = 0.0; // Starts at 0, max 100
  Map<String, dynamic>? _publishData;

  bool _isLoading = false;
  bool _isComplete = false;
  String? _errorMessage;
  String _userIdea = '';

  // ── Getters ───────────────────────────────────────
  List<ChatMessage> get messages =>
      _messages.where((m) => m.type != MessageType.system).toList();
  List<DecisionOption> get currentOptions => List.unmodifiable(_currentOptions);
  String get currentAnalysis => _currentAnalysis;
  String get currentQuestion => _currentQuestion;
  String? get currentPhaseLabel => _currentPhaseLabel;
  double get budgetRemaining => _budgetRemaining;
  double get effectiveValue => _effectiveValue;
  Map<String, dynamic>? get publishData => _publishData;
  bool get isLoading => _isLoading;
  bool get isComplete => _isComplete;
  String? get errorMessage => _errorMessage;
  String get userIdea => _userIdea;

  double get progress {
    if (AppConstants.coreAspects.isEmpty) return 0;
    return _coveredAspects.length / AppConstants.coreAspects.length;
  }

  VicharaneEngine({OpenRouterService? apiService})
      : _apiService = apiService ?? OpenRouterService();

  // ── Public API ────────────────────────────────────

  Future<void> startSession(String idea) async {
    _userIdea = idea.trim();
    _resetState();

    _messages.add(ChatMessage.system(_buildSystemPrompt()));
    _messages.add(ChatMessage.user('My idea: $_userIdea\n\n[SYSTEM: Apply the 80/20 rule to this idea and present the first operational problem.]'));

    notifyListeners();
    await _getAiResponse();
  }

  Future<void> selectOption(DecisionOption option) async {
    if (_isLoading) return;
    _messages.add(ChatMessage.user(option.title));
    _currentOptions.clear();
    notifyListeners();
    await _getAiResponse();
  }

  Future<void> sendCustomResponse(String text) async {
    if (_isLoading || text.trim().isEmpty) return;
    _messages.add(ChatMessage.user(text.trim()));
    _currentOptions.clear();
    notifyListeners();
    await _getAiResponse();
  }

  /// Triggers a sudden stakeholder scenario
  Future<void> triggerBargainScenario() async {
    if (_isLoading) return;
    _messages.add(ChatMessage.user('[SYSTEM: The user pressed BARGAIN. Immediately drop the current topic. Create a sudden, high-stakes roleplay scenario where you are a strict Government Official, local leader, or angry supplier. Explain the conflict and give them 3 dialogue choices to resolve it.]'));
    _currentOptions.clear();
    notifyListeners();
    await _getAiResponse();
  }

  /// Tells the AI to wrap up and generate Publisher JSON
  Future<void> triggerPublishIdea() async {
    if (_isLoading) return;
    _messages.add(ChatMessage.user('[SYSTEM: The user pressed PUBLISH. The simulation is now over. Analyze their performance, their remaining budget, and their idea. Set is_complete to true, and generate the final "summary" JSON object matching the database schema so we can publish them to Investors.]'));
    _currentOptions.clear();
    notifyListeners();
    await _getAiResponse();
  }

  void reset() {
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _messages.clear();
    _currentOptions.clear();
    _coveredAspects.clear();
    _budgetRemaining = 500000.0;
    _effectiveValue = 0.0;
    _publishData = null;
    _currentAnalysis = '';
    _currentQuestion = '';
    _currentPhaseLabel = null;
    _isComplete = false;
    _isLoading = false;
    _errorMessage = null;
  }

  // ── Private Methods ───────────────────────────────

  Future<void> _getAiResponse() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiMessages = _messages.map((m) => m.toApiFormat()).toList();
      final responseText = await _apiService.sendMessage(apiMessages);
      final parsed = _parseAiResponse(responseText);

      if (parsed != null) {
        _currentAnalysis = parsed['analysis'] ?? '';
        _currentQuestion = parsed['question'] ?? '';
        _currentPhaseLabel = parsed['phase_label'];
        
        // Update Budget metrics
        if (parsed['budget_remaining'] != null) {
          _budgetRemaining = (parsed['budget_remaining'] as num).toDouble();
        }
        if (parsed['effective_value'] != null) {
          _effectiveValue = (parsed['effective_value'] as num).toDouble();
        }

        if (parsed['is_complete'] == true) {
          _isComplete = true;
          _currentOptions.clear();
          _publishData = parsed['summary']; // Save the structured data for Firestore!
          _messages.add(ChatMessage.ai(responseText, metadata: {'type': 'summary'}));
        } else {
          final optionsList = parsed['options'] as List<dynamic>?;
          if (optionsList != null) {
            _currentOptions = optionsList.map((o) => DecisionOption.fromJson(o as Map<String, dynamic>)).toList();
          }

          final displayText = StringBuffer();
          if (_currentAnalysis.isNotEmpty) displayText.writeln(_currentAnalysis);
          if (_currentQuestion.isNotEmpty) {
            displayText.writeln();
            displayText.write('**$_currentQuestion**');
          }

          _messages.add(ChatMessage.ai(displayText.toString().trim(), metadata: {'type': 'decision_point'}));
        }
      } else {
        _messages.add(ChatMessage.ai(responseText, metadata: {'type': 'raw_response'}));
        _currentOptions.clear();
      }
    } on OpenRouterException catch (e) {
      _errorMessage = e.message;
      _messages.add(ChatMessage.ai('⚠️ Error: ${e.message}'));
    } catch (e) {
      _errorMessage = e.toString();
      _messages.add(ChatMessage.ai('⚠️ Core Error: $e'));
    }

    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic>? _parseAiResponse(String response) {
    try {
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true).firstMatch(response);
      if (jsonMatch != null) return jsonDecode(jsonMatch.group(1)!.trim());
      if (response.trimLeft().startsWith('{')) return jsonDecode(response.trim());
      return null;
    } catch (e) {
      return null;
    }
  }

  String _buildSystemPrompt() {
    return '''
You are **Vicharane**, an extremely strict AI evaluator for a Social Impact platform.
The user is a Startup Founder. They want investor money. Your job is to test their execution skills before they are allowed to Publish their idea to investors.

## 1. THE 80/20 BUDGET VIRTUAL ACCOUNT
The user starts with ₹500000 budget_remaining and 0 effective_value.
At EVERY step, you must pose an operational problem. The options you provide MUST have hidden costs.
- "Expensive UI/UX Agency" (Costs ₹200000, adds 10 value).
- "Use free Google Forms" (Costs ₹0, adds 15 value).
If the user picks the expensive one, you must correctly subtract ₹200000 from budget_remaining in your NEXT response. If they hit 0, they fail.

## 2. GOVERNMENT COLLABORATOR
You must actively suggest existing Indian/Global Government schemes they could partner with to save money.

## 3. RESPONSE FORMAT (MANDATORY JSON)
Always return EXACTLY this JSON format inside ```json ... ``` tags:
{
  "phase_label": "e.g., Resource Allocation",
  "budget_remaining": <int - deduct based on their last choice>,
  "effective_value": <int - increase if they made a smart choice>,
  "analysis": "2 sentence critique of their last choice",
  "question": "The next scenario/dilemma",
  "options": [
    {"id": "o1", "title": "Choice 1", "description": "...", "icon": "rocket"},
    {"id": "o2", "title": "Choice 2", "description": "...", "icon": "money"},
    {"id": "o3", "title": "Choice 3", "description": "...", "icon": "handshake"}
  ],
  "is_complete": false
}

## 4. WHEN TRIGGERED TO PUBLISH
If the user's prompt begins with [SYSTEM: The user pressed PUBLISH], stop asking questions.
Set is_complete to true, and output this specific summary JSON:
{
  "phase_label": "Ready for Investors",
  "budget_remaining": 0,
  "effective_value": 0,
  "analysis": "Final review...",
  "question": "",
  "options": [],
  "is_complete": true,
  "summary": {
    "title": "A catchy name for their idea",
    "description": "A refined 2-sentence pitch based on their chat",
    "impact_score": <int 1-100 based on their performance>,
    "budget_needed": <int - how much money they legitimately need from investors>
  }
}
''';
  }
}
