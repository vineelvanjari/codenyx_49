import 'package:flutter/material.dart';

/// Represents one decision option presented to the user.
///
/// At each decision point, the AI generates 3-4 of these options.
/// Each has a title, description, and icon to help the user
/// quickly understand what the option means.
///
/// The [id] is used to track which option was selected.
class DecisionOption {
  final String id;
  final String title;
  final String description;
  final String iconName;

  const DecisionOption({
    required this.id,
    required this.title,
    required this.description,
    this.iconName = 'lightbulb',
  });

  /// Parse from JSON (returned by the LLM)
  factory DecisionOption.fromJson(Map<String, dynamic> json) {
    return DecisionOption(
      id: json['id'] as String? ?? 'opt_unknown',
      title: json['title'] as String? ?? 'Option',
      description: json['description'] as String? ?? '',
      iconName: json['icon'] as String? ?? 'lightbulb',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': iconName,
    };
  }

  /// Map icon name strings to Flutter IconData.
  /// The LLM returns icon names as strings — we map them here.
  IconData get icon {
    const iconMap = {
      'lightbulb': Icons.lightbulb_outline,
      'people': Icons.people_outline,
      'school': Icons.school_outlined,
      'phone': Icons.phone_android_outlined,
      'location': Icons.location_on_outlined,
      'money': Icons.attach_money,
      'health': Icons.health_and_safety_outlined,
      'rocket': Icons.rocket_launch_outlined,
      'shield': Icons.shield_outlined,
      'chart': Icons.bar_chart_outlined,
      'globe': Icons.public_outlined,
      'handshake': Icons.handshake_outlined,
      'building': Icons.business_outlined,
      'elderly': Icons.elderly_outlined,
      'volunteer': Icons.volunteer_activism_outlined,
      'agriculture': Icons.agriculture_outlined,
      'water': Icons.water_drop_outlined,
      'education': Icons.auto_stories_outlined,
      'tech': Icons.devices_outlined,
      'community': Icons.groups_outlined,
      'government': Icons.account_balance_outlined,
      'timeline': Icons.timeline_outlined,
      'warning': Icons.warning_amber_outlined,
      'budget': Icons.account_balance_wallet_outlined,
      'target': Icons.track_changes_outlined,
      'expand': Icons.open_in_full_outlined,
      'hybrid': Icons.merge_type_outlined,
      'scale': Icons.scale_outlined,
      'strategy': Icons.psychology_outlined,
    };

    return iconMap[iconName] ?? Icons.lightbulb_outline;
  }
}
