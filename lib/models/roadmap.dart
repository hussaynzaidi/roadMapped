class Roadmap {
  final String id;
  final String title;
  final String description;
  final List<RoadmapStep> steps;
  final String createdBy;
  final DateTime createdAt;
  final bool isPublic;
<<<<<<< HEAD
  final double progress;
=======
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676

  Roadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.createdBy,
    required this.createdAt,
    this.isPublic = true,
<<<<<<< HEAD
    this.progress = 0.0,
=======
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
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
<<<<<<< HEAD
      progress: json['progress']?.toDouble() ?? 0.0,
=======
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
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
<<<<<<< HEAD
        'progress': progress,
=======
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
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
