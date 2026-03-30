import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../config/constants.dart';

/// Splash screen — first thing the user sees.
///
/// DESIGN:
/// - Animated logo and brand name
/// - Tagline fades in after brand
/// - Gradient background with subtle glow
/// - Auto-navigates to idea input after 3 seconds
///
/// WHY A SPLASH:
/// Sets the premium tone immediately. The user's first impression
/// determines whether they take the app seriously.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/idea-input');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF1a1040), Color(0xFF0A0E1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Background Glow ──
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.5 - 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo icon
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  FadeIn(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      AppConstants.appName,
                      style: AppTypography.heading1.copyWith(
                        fontSize: 36,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sanskrit meaning
                  FadeIn(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'विचारणे',
                      style: AppTypography.subtitle.copyWith(
                        fontSize: 20,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    duration: const Duration(milliseconds: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom loading indicator ──
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
