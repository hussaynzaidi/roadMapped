import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks a user's progress through a roadmap.
/// 
/// This model maintains:
/// - Completion status of individual steps via [completedSteps]
/// - Start and completion timestamps
/// - Overall progress percentage
/// - User and roadmap associations
/// 
/// The [progressPercentage] is automatically calculated based on completed steps.
class RoadmapProgress {
  /// Unique identifier for the progress record
  final String id;

  /// ID of the user tracking this roadmap
  final String userId;

  /// ID of the roadmap being tracked
  final String roadmapId;

  /// Map of step IDs to their completion status
  /// Key: Step ID, Value: Whether step is completed
  final Map<String, bool> completedSteps;

  /// When the user started this roadmap
  final DateTime startedAt;

  /// When the user completed all steps (null if incomplete)
  final DateTime? completedAt;

  /// Percentage of steps completed (0.0 to 1.0)
  final double progressPercentage;

  RoadmapProgress({
    required this.id,
    required this.userId,
    required this.roadmapId,
    required this.completedSteps,
    required this.startedAt,
    this.completedAt,
    required this.progressPercentage,
  });

  factory RoadmapProgress.fromJson(Map<String, dynamic> json) {
    return RoadmapProgress(
      id: json['id'],
      userId: json['userId'],
      roadmapId: json['roadmapId'],
      completedSteps: Map<String, bool>.from(json['completedSteps'] ?? {}),
      startedAt: (json['startedAt'] is Timestamp) 
          ? (json['startedAt'] as Timestamp).toDate()
          : DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp)
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt'])
          : null,
      progressPercentage: json['progressPercentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'roadmapId': roadmapId,
        'completedSteps': completedSteps,
        'startedAt': Timestamp.fromDate(startedAt),
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'progressPercentage': progressPercentage,
      };

  RoadmapProgress copyWith({
    Map<String, bool>? completedSteps,
    DateTime? completedAt,
    double? progressPercentage,
  }) {
    return RoadmapProgress(
      id: id,
      userId: userId,
      roadmapId: roadmapId,
      completedSteps: completedSteps ?? this.completedSteps,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}
