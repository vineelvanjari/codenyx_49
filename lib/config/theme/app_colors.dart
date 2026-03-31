import 'package:flutter/material.dart';

/// App color palette — startup-focused, bold, modern.
///
/// WHY THESE COLORS:
/// - Deep dark surfaces → premium feel, reduces eye strain
/// - Electric violet primary → energy, innovation, ambition
/// - Emerald accent → growth, impact, sustainability
/// - Amber warning → risk awareness, caution
///
/// Usage: AppColors.primary, AppColors.surface, etc.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ── Brand Primary ──────────────────────────────────
  // Electric violet → conveys innovation & ambition
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B21B6);

  // ── Surfaces (Dark Mode) ───────────────────────────
  // Deep navy-black → premium, modern startup feel
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1F2937);
  static const Color surfaceLighter = Color(0xFF374151);

  // ── Surfaces (Light Mode) ──────────────────────────
  static const Color backgroundLightMode = Color(0xFFF4F6F8);
  static const Color surfaceLightMode = Color(0xFFFFFFFF);
  static const Color surfaceLighterMode = Color(0xFFF9FAFB);

  // ── Accent Colors ─────────────────────────────────
  // Emerald → growth, social impact, sustainability
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);

  // Amber → risks, warnings, attention needed
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);

  // Rose → errors, critical issues
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);

  // Cyan → information, insights, data
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF22D3EE);

  // ── Text Colors (Dark Mode) ───────────────────────
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ── Text Colors (Light Mode) ──────────────────────
  static const Color textPrimaryLightMode = Color(0xFF111827);
  static const Color textSecondaryLightMode = Color(0xFF4B5563);
  static const Color textMutedLightMode = Color(0xFF9CA3AF);

  // ── Gradients ─────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF0A0E1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Glass Effect ──────────────────────────────────
  // Semi-transparent surfaces for glassmorphism cards
  static Color glassWhite = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);
  static Color glassBorderDark = Colors.black.withValues(alpha: 0.1);
}
