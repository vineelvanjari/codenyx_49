import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme/app_colors.dart';
import '../../core/services/demo_session.dart';

class StartupDashboard extends StatelessWidget {
  const StartupDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Sandbox Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              DemoSession.clear();
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AI Simulation Launch ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Vicharane Simulator',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test your idea, manage your budget, and earn your Execution Score.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/idea-input');
                    },
                    child: const Text('Start Sandbox', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── News Monitor ──
            const Text(
              'Live AI Market Monitor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildNewsCard(
              title: "Government releases ₹500Cr Rural Tech Grant",
              insight: "PROFIT OPPORTUNITY: Your platform may qualify for this. Check the 'StartUp India' portal.",
              isPositive: true,
              isDark: isDark,
            ),
            _buildNewsCard(
              title: "Global hardware supply chain delays expected",
              insight: "LOSS RISK: Your distribution model may face cost increases. Pivot to software-only.",
              isPositive: false,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard({required String title, required String insight, required bool isPositive, required bool isDark}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isPositive ? Icons.trending_up : Icons.warning_amber_rounded, color: isPositive ? Colors.greenAccent : Colors.orangeAccent),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPositive 
                    ? Colors.green.withValues(alpha: isDark ? 0.1 : 0.05) 
                    : Colors.orange.withValues(alpha: isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(insight, style: TextStyle(
                color: isPositive 
                    ? (isDark ? Colors.greenAccent : Colors.green) 
                    : (isDark ? Colors.orangeAccent : Colors.orange[800])
              )),
            )
          ],
        ),
      ),
    );
  }
}
