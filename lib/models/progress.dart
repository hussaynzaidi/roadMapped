class RoadmapProgress {
  final String id;
  final String userId;
  final String roadmapId;
  final Map<String, bool> completedSteps;
  final DateTime startedAt;
  final DateTime? completedAt;
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
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      progressPercentage: json['progressPercentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'roadmapId': roadmapId,
        'completedSteps': completedSteps,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
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
