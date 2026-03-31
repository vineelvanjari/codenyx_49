import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/demo_session.dart';
import '../../core/models/idea_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import 'package:animate_do/animate_do.dart';

class GigBoard extends StatelessWidget {
  const GigBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech for Good: Bounties'),
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
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: BountyHeader(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 150 * index),
                    child: GigCard(idea: _getMockGigs()[index]),
                  );
                },
                childCount: _getMockGigs().length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💥 HEROIC RESCUE: Static Mock Data to bypass Firebase Index!
  List<IdeaModel> _getMockGigs() {
    return [
      IdeaModel(
        id: '1',
        startupUid: 'founderA',
        title: 'Build Offline-Sync Data Model for EduBlock',
        description: 'We need a senior Flutter / Hive developer to architect an offline-first resilient sync engine. The device will be in villages with 2G drops.',
        budgetNeeded: 0,
        allocatedFunds: 85000, // Tech bounty
        impactScore: 88,
        status: 'funded',
        createdAt: DateTime.now(),
      ),
      IdeaModel(
        id: '2',
        startupUid: 'founderB',
        title: 'Integrate OpenRouter AI for TeleTriage',
        description: 'Our rural telemedicine platform needs a lightweight Chatbot triage built in Flutter hooked to Llama-3 via OpenRouter. Fix our CORS issues!',
        budgetNeeded: 0,
        allocatedFunds: 120000, // Tech bounty
        impactScore: 92,
        status: 'funded',
        createdAt: DateTime.now(),
      ),
      IdeaModel(
        id: '3',
        startupUid: 'founderC',
        title: 'Micro-Payment Gateway for Artisans',
        description: 'Integrate UPI and Razorpay into our supply chain tracking app so rural artisans get paid instantly upon delivery validation.',
        budgetNeeded: 0,
        allocatedFunds: 50000, // Tech bounty
        impactScore: 80,
        status: 'funded',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

class BountyHeader extends StatelessWidget {
  const BountyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.purpleAccent.withValues(alpha: 0.3) : Colors.purple.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Colors.purpleAccent, size: 36),
              const SizedBox(width: 12),
              Text(
                'Build the Future.',
                style: AppTypography.heading1.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'These social-enterprises have secured VC funding.\nClaim their bounties, write code, and change the world.',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class GigCard extends StatelessWidget {
  final IdeaModel idea;

  const GigCard({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 6 : 12,
      shadowColor: isDark ? Colors.black54 : Colors.purpleAccent.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark 
                ? [AppColors.surfaceLight, AppColors.surface]
                : [Colors.white, const Color(0xFFFAFAFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('ESCROWED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                    const Icon(Icons.bookmark_border, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  idea.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading2.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  idea.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
            
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bounty Pool', style: AppTypography.label.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
                    Text('₹${idea.allocatedFunds.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purpleAccent)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gig Claimed! The founder of ${idea.title} has been notified natively.'),
                          backgroundColor: Colors.purple,
                        )
                      );
                    },
                    child: const Text('Claim Protocol', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
