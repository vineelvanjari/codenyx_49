import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../config/env.dart';

/// OpenRouter API service — handles all LLM communication.
///
/// HOW OPENROUTER WORKS:
/// - It's an API proxy that gives you access to many LLMs
///   (Gemini, Claude, GPT, etc.) with a single API key.
/// - The API format is similar to OpenAI's chat completions.
/// - We send a list of messages (system + conversation history)
///   and get back the AI's response.
///
/// USAGE:
///   final service = OpenRouterService();
///   final response = await service.sendMessage(messages);
class OpenRouterService {
  final String _model;
  final http.Client _client;

  OpenRouterService({
    String? model,
    http.Client? client,
  })  : _model = model ?? AppConstants.defaultModel,
        _client = client ?? http.Client();

  /// Send a conversation to the LLM and get a response.
  ///
  /// [messages] — list of {role: 'system'|'user'|'assistant', content: '...'}
  /// Returns the AI's response text, or throws on error.
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    final apiKey = Env.openRouterApiKey;

    final body = jsonEncode({
      'model': _model,
      'messages': messages,
      'temperature': 0.7, // Creative but not chaotic
      'max_tokens': 1024, // Enough for analysis + options
    });

    try {
      final response = await _client
          .post(
            Uri.parse(AppConstants.openRouterBaseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://vicharane.app', // Required by OpenRouter
              'X-Title': AppConstants.appName,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];

        if (content == null || content.isEmpty) {
          throw OpenRouterException('Empty response from AI');
        }

        return content as String;
      } else {
        // Parse error message from response
        final errorData = jsonDecode(response.body);
        final errorMsg =
            errorData['error']?['message'] ?? 'Unknown error occurred';
        throw OpenRouterException(
          'API Error (${response.statusCode}): $errorMsg',
        );
      }
    } on OpenRouterException {
      rethrow;
    } catch (e) {
      throw OpenRouterException('Network error: $e');
    }
  }

  /// Clean up the HTTP client when done
  void dispose() {
    _client.close();
  }
}

/// Custom exception for OpenRouter errors — makes error handling cleaner.
class OpenRouterException implements Exception {
  final String message;
  OpenRouterException(this.message);

  @override
  String toString() => 'OpenRouterException: $message';
}
