import 'package:cloud_firestore/cloud_firestore.dart';

class IdeaModel {
  final String id;
  final String startupUid;
  final String title;
  final String description;
  final int impactScore;
  final double budgetNeeded;
  final double allocatedFunds;
  final String status; // 'published', 'funded', 'active'
  final DateTime createdAt;

  IdeaModel({
    required this.id,
    required this.startupUid,
    required this.title,
    required this.description,
    required this.impactScore,
    required this.budgetNeeded,
    this.allocatedFunds = 0.0,
    this.status = 'published',
    required this.createdAt,
  });

  factory IdeaModel.fromMap(Map<String, dynamic> data, String documentId) {
    return IdeaModel(
      id: documentId,
      startupUid: data['startupUid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      impactScore: data['impactScore'] ?? 0,
      budgetNeeded: (data['budgetNeeded'] ?? 0).toDouble(),
      allocatedFunds: (data['allocatedFunds'] ?? 0).toDouble(),
      status: data['status'] ?? 'published',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupUid': startupUid,
      'title': title,
      'description': description,
      'impactScore': impactScore,
      'budgetNeeded': budgetNeeded,
      'allocatedFunds': allocatedFunds,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
