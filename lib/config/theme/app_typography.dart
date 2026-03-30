import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography system using Google Fonts.
///
/// WHY THESE FONTS:
/// - Outfit → geometric, modern, startup-friendly for headings
/// - Inter → highly readable, clean for body text & chat messages
///
/// Usage: AppTypography.heading1, AppTypography.body, etc.
class AppTypography {
  AppTypography._();

  // ── Headings (Outfit) ─────────────────────────────
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  static TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  static TextStyle subtitle = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF9CA3AF),
    height: 1.4,
  );

  // ── Body Text (Inter) ─────────────────────────────
  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFF9FAFB),
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF9CA3AF),
    height: 1.5,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF6B7280),
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ── Button Text ───────────────────────────────────
  static TextStyle button = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.0,
  );

  static TextStyle buttonSmall = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.0,
  );

  // ── Chat-specific ─────────────────────────────────
  static TextStyle chatMessage = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFF9FAFB),
    height: 1.6,
  );

  static TextStyle chatOption = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.4,
  );
}
