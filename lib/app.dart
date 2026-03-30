import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/idea_input/idea_input_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/summary/summary_screen.dart';

/// App shell — MaterialApp with routing and theme.
///
/// ROUTING:
///   '/'            → SplashScreen (auto-redirects after 3s)
///   '/idea-input'  → IdeaInputScreen (user types their idea)
///   '/chat'        → ChatScreen (decision tree conversation)
///   '/summary'     → SummaryScreen (final roadmap)
class VicharaneApp extends StatelessWidget {
  const VicharaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // ── Routes ──
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/idea-input': (context) => const IdeaInputScreen(),
        '/chat': (context) => const ChatScreen(),
        '/summary': (context) => const SummaryScreen(),
      },
    );
  }
}
