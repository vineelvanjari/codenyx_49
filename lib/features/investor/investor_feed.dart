import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/demo_session.dart';
import '../../core/models/idea_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import 'package:animate_do/animate_do.dart';

class InvestorFeed extends StatelessWidget {
  const InvestorFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('De-Risked Deal Flow'),
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: PremiumVCHeader(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: DealCard(
                      idea: _getMockDeals()[index], 
                      isDarkMode: Theme.of(context).brightness == Brightness.dark
                    ),
                  );
                },
                childCount: _getMockDeals().length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💥 HEROIC RESCUE: Static Mock Data to bypass Firebase Index requirements!
  List<IdeaModel> _getMockDeals() {
    return [
      IdeaModel(
        id: '1',
        startupUid: 'founder1',
        title: 'AgriSense IoT Platform',
        description: 'Low-cost soil moisture sensors connected to a hyper-local weather AI. Helps smallholder farmers optimize water usage and predicts crop diseases 2 weeks in advance.',
        budgetNeeded: 2500000,
        allocatedFunds: 1250000,
        impactScore: 94,
        status: 'published',
        createdAt: DateTime.now(),
      ),
      IdeaModel(
        id: '2',
        startupUid: 'founder2',
        title: 'EduBlock: Rural Literacy',
        description: 'An offline-first mesh network router delivering gamified primary curriculum updates to village tablets without requiring active internet broadband.',
        budgetNeeded: 1200000,
        allocatedFunds: 800000,
        impactScore: 88,
        status: 'published',
        createdAt: DateTime.now(),
      ),
      IdeaModel(
        id: '3',
        startupUid: 'founder3',
        title: 'Solar Water Purifiers',
        description: 'Modular, community-maintained solar distillation units that convert contaminated groundwater into safe drinking water for communities under 5,000 people.',
        budgetNeeded: 4500000,
        allocatedFunds: 500000,
        impactScore: 97,
        status: 'published',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

class PremiumVCHeader extends StatelessWidget {
  const PremiumVCHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.primaryDark, AppColors.background]
              : [AppColors.primaryLight.withValues(alpha: 0.3), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderDark.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('Capital Pool', '₹15,000Cr', Icons.account_balance_wallet, isDark),
          _buildStat('Active Deals', '142', Icons.show_chart, isDark),
          _buildStat('Avg ESG', '89', Icons.psychology, isDark),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: isDark ? AppColors.accentLight : AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.label.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            )),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.heading2.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 22,
        )),
      ],
    );
  }
}

class DealCard extends StatelessWidget {
  final IdeaModel idea;
  final bool isDarkMode;

  const DealCard({super.key, required this.idea, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    // Determine progress
    double progress = 0;
    if (idea.budgetNeeded > 0) {
      progress = idea.allocatedFunds / idea.budgetNeeded;
      if (progress > 1) progress = 1;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: isDarkMode ? 4 : 10,
      shadowColor: AppColors.glassBorderDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    idea.title,
                    style: AppTypography.heading2.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'AI Score: ${idea.impactScore}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              idea.description,
              style: AppTypography.bodyMedium.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Funding Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Funding Goal', style: AppTypography.label.copyWith(color: isDarkMode ? Colors.white54 : Colors.black54)),
                Text(
                  '₹${idea.allocatedFunds.toStringAsFixed(0)} / ₹${idea.budgetNeeded.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: isDarkMode ? AppColors.surfaceLighter : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: 24),

            // Escrow Funding Action
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 5,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transacting Escrow to ${idea.title}...'),
                      backgroundColor: AppColors.primaryDark,
                    )
                  );
                  await FirestoreService().allocateFunds(idea.id, idea.budgetNeeded);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Fund Escrow Securely',
                      style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
