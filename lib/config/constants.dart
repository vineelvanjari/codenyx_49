/// App-wide constants.
///
/// Centralized place for magic strings, URLs, default values.
/// If you need to change an API endpoint or model name,
/// change it here — not scattered across the codebase.
class AppConstants {
  AppConstants._();

  // ── App Info ───────────────────────────────────────
  static const String appName = 'ImpactForge';
  static const String appTagline =
      'Think before you build. Build while you learn.';

  // ── OpenRouter API ────────────────────────────────
  static const String openRouterBaseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  /// Default model — Gemini 2.0 Flash (fast, affordable)
  static const String defaultModel = 'google/gemini-2.0-flash-001';

  // ── Decision Tree ─────────────────────────────────
  /// Key aspects the Vicharane engine should cover dynamically.
  /// The AI uses these as a checklist — order and depth vary per idea.
  static const List<String> coreAspects = [
    'Problem Understanding & Scope',
    'Target Audience & Beneficiaries',
    'Solution & Delivery Model',
    'Stakeholder & Partnership Strategy',
    'Revenue & Financial Sustainability',
    'Risk Assessment & Mitigation',
    'Resource Allocation & Budget',
    'Roadmap & Execution Plan',
  ];

  // ── UI Constants ──────────────────────────────────
  static const double maxChatWidth = 720.0;
  static const double cardBorderRadius = 16.0;
  static const double inputBorderRadius = 12.0;
}
