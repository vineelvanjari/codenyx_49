import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/idea_input/idea_input_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/summary/summary_screen.dart';
import 'features/auth/auth_gate.dart';
import 'features/startup/startup_dashboard.dart';
import 'features/investor/investor_feed.dart';
import 'features/developer/gig_board.dart';

/// Global notifier to track the chosen theme mode (defaults to light).
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(ThemeMode.light);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // ── Theme ──
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          // ── Routes ──
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/idea-input': (context) => const IdeaInputScreen(),
            '/chat': (context) => const ChatScreen(),
            '/summary': (context) => const SummaryScreen(),
            '/auth-gate': (context) => const AuthGate(),
            '/startup': (context) => const StartupDashboard(),
            '/investor': (context) => const InvestorFeed(),
            '/developer': (context) => const GigBoard(),
          },
        );
      },
    );
  }
}
