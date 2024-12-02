class Roadmap {
  final String id;
  final String title;
  final String description;
  final List<RoadmapStep> steps;
  final String createdBy;
  final DateTime createdAt;
  final bool isPublic;

  Roadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.createdBy,
    required this.createdAt,
    this.isPublic = true,
  });

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      steps: (json['steps'] as List)
          .map((step) => RoadmapStep.fromJson(step))
          .toList(),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      isPublic: json['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'steps': steps.map((step) => step.toJson()).toList(),
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'isPublic': isPublic,
      };
}

class RoadmapStep {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
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
