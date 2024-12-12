import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final List<String> completedRoadmaps;
  final List<String> createdRoadmaps;
  final Map<String, bool>
      medals; // e.g., {'creator_5': true, 'completer_10': true}

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.completedRoadmaps = const [],
    this.createdRoadmaps = const [],
    this.medals = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
      'completedRoadmaps': completedRoadmaps,
      'createdRoadmaps': createdRoadmaps,
      'medals': medals,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      completedRoadmaps: List<String>.from(json['completedRoadmaps'] ?? []),
      createdRoadmaps: List<String>.from(json['createdRoadmaps'] ?? []),
      medals: Map<String, bool>.from(json['medals'] ?? {}),
    );
  }
}
