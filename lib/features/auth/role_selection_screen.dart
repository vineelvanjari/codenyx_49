import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  final User user;

  const RoleSelectionScreen({super.key, required this.user});

  void _selectRole(BuildContext context, String role) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await FirestoreService().updateUserRole(user.uid, role);
    
    // AuthGate will re-build and automatically route us because we are popping back
    if (context.mounted) {
      Navigator.of(context).pop(); // remove loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How will you change the world today?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildRoleCard(
            context,
            icon: Icons.lightbulb,
            title: 'I am a Startup',
            description: 'Test my idea, learn execution, and find funding.',
            role: 'startup',
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            context,
            icon: Icons.monetization_on,
            title: 'I am an Investor',
            description: 'Fund proven, de-risked social initiatives.',
            role: 'investor',
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            context,
            icon: Icons.code,
            title: 'I am a Developer',
            description: 'Build tech for funded social projects.',
            role: 'developer',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required IconData icon, required String title, required String description, required String role, required Color color}) {
    return InkWell(
      onTap: () => _selectRole(context, role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 5),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
