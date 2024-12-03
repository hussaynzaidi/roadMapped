import 'package:cloud_firestore/cloud_firestore.dart';

/// A model representing a learning roadmap.
/// 
/// Contains information about the roadmap including:
/// - Basic details (title, description)
/// - Steps to complete
/// - Creation metadata
/// - Visibility settings
/// 
/// The [progress] field represents the overall completion percentage.
class Roadmap {
  final String id;
  final String title;
  final String description;
  final List<RoadmapStep> steps;
  final String createdBy;
  final DateTime createdAt;
  final bool isPublic;
  final double progress;

  Roadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.createdBy,
    required this.createdAt,
    this.isPublic = true,
    this.progress = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'progress': progress,
    };
  }

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List)
          .map((step) => RoadmapStep.fromJson(step))
          .toList(),
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isPublic: json['isPublic'] as bool,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Represents a single step in a learning roadmap.
/// 
/// Each step contains:
/// - Unique identifier
/// - Title and description of the learning objective
/// - Completion status tracking
/// - Associated learning resources
/// 
/// Resources can be links, files, or text content that help
/// complete the learning objective.
class RoadmapStep {
  /// Unique identifier for the step
  final String id;

  /// Title describing the learning objective
  final String title;

  /// Detailed description of what needs to be learned
  final String description;

  /// Whether this step has been completed
  final bool isCompleted;

  /// List of resource IDs associated with this step
  final List<String> resources;

  RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.resources = const [],
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      resources: List<String>.from(json['resources'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'resources': resources,
      };
}
