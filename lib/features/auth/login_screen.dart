import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/demo_session.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark App Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text(
                'ImpactForge',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to change the world.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Google Login (Original)
              ElevatedButton.icon(
                icon: const Icon(Icons.security, size: 24, color: Colors.blueAccent),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  await AuthService().signInWithGoogle();
                },
              ),
              const SizedBox(height: 40),
              
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),
              const Text(
                '--- BUG-FREE DEMO LOGIN ---',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1.5),
              ),
              const SizedBox(height: 20),

              // 1. Startup Demo
              ElevatedButton.icon(
                icon: const Icon(Icons.lightbulb, color: Colors.amber),
                label: const Text('Login as Startup\nvineelvanjari24@gmail.com', textAlign: TextAlign.center),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () => _handleDemoLogin(context, 'demo_startup', 'vineelvanjari24@gmail.com', 'startup', '/startup'),
              ),
              const SizedBox(height: 12),

              // 2. Investor Demo
              ElevatedButton.icon(
                icon: const Icon(Icons.monetization_on, color: Colors.greenAccent),
                label: const Text('Login as Investor\nvineelvanjari48@gmail.com', textAlign: TextAlign.center),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () => _handleDemoLogin(context, 'demo_investor', 'vineelvanjari48@gmail.com', 'investor', '/investor'),
              ),
              const SizedBox(height: 12),

              // 3. Developer Demo
              ElevatedButton.icon(
                icon: const Icon(Icons.code, color: Colors.purpleAccent),
                label: const Text('Login as Developer\nvineelvanjari36@gmail.com', textAlign: TextAlign.center),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
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
