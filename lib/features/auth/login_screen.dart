import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/demo_session.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../app.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleDemoLogin(BuildContext context, String uid, String email, String role, String routeName) async {
    // 1. Set the Demo Session
    DemoSession.setSession(uid, email, role);
    
    // 2. Ensure Firestore has a document for this Demo User
    try {
      await FirestoreService().updateUserRole(uid, role);
    } catch (e) {
      debugPrint('Firestore write ignored safely in Demo Mode: $e');
    }
    
    // 3. Navigate straight to the designated Dashboard!
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.backgroundLightMode,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              appThemeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(
                 Icons.rocket_launch, 
                 size: 80, 
                 color: isDark ? Colors.blueAccent : AppColors.primary
              ),
              const SizedBox(height: 16),
              Text(
                'ImpactForge',
                style: AppTypography.heading1.copyWith(
                  fontSize: 32, 
                  color: isDark ? Colors.white : Colors.black
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to change the world.',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 16, 
                  color: isDark ? Colors.grey : AppColors.textSecondaryLightMode
                ),
              ),
              const SizedBox(height: 40),
              
              // Google Login (Original)
              ElevatedButton.icon(
                icon: Icon(Icons.security, size: 24, color: isDark ? Colors.blueAccent : Colors.white),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : AppColors.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  await AuthService().signInWithGoogle();
                },
              ),
              const SizedBox(height: 40),
              
              Divider(color: isDark ? Colors.white24 : Colors.black12),
              const SizedBox(height: 20),
              Text(
                '--- BUG-FREE DEMO LOGIN ---',
                style: AppTypography.label.copyWith(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.amber : Colors.orange[800], 
                  letterSpacing: 1.5
                ),
              ),
              const SizedBox(height: 20),

              // 1. Startup Demo
              ElevatedButton.icon(
                icon: Icon(Icons.lightbulb, color: isDark ? Colors.amber : Colors.orange),
                label: const Text('Login as Startup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () => _handleDemoLogin(context, 'demo_startup', 'vineelvanjari24@gmail.com', 'startup', '/startup'),
              ),
              const SizedBox(height: 12),

              // 2. Investor Demo
              ElevatedButton.icon(
                icon: Icon(Icons.monetization_on, color: isDark ? Colors.greenAccent : Colors.green),
                label: const Text('Login as Investor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () => _handleDemoLogin(context, 'demo_investor', 'vineelvanjari48@gmail.com', 'investor', '/investor'),
              ),
              const SizedBox(height: 12),

              // 3. Developer Demo
              ElevatedButton.icon(
                icon: Icon(Icons.code, color: isDark ? Colors.purpleAccent : AppColors.primary),
                label: const Text('Login as Developer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () => _handleDemoLogin(context, 'demo_developer', 'vineelvanjari36@gmail.com', 'developer', '/developer'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
