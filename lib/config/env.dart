import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration — reads values from .env file.
///
/// HOW IT WORKS:
/// 1. We load .env in main.dart before runApp()
/// 2. This class provides typed access to env variables
/// 3. If a key is missing, it throws with a clear error message
///
/// WHY: Keeps API keys out of source code → secure, gitignored.
class Env {
  Env._();

  /// OpenRouter API key from .env file
  static String get openRouterApiKey {
    final key = dotenv.env['OPENROUTER_API_KEY'];
    if (key == null || key.isEmpty || key == 'your_openrouter_api_key_here') {
      throw Exception(
        'OPENROUTER_API_KEY not set!\n'
        'Open .env file and replace the placeholder with your actual key.\n'
        'Get one at: https://openrouter.ai/keys',
      );
    }
    return key;
  }
}
