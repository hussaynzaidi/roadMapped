import 'package:cloud_firestore/cloud_firestore.dart';

enum ResourceType {
  link,
  text,
}

class Resource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String content; // URL for links or text content
  final DateTime createdAt;
  final String createdBy;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ResourceType.link,
      ),
      content: json['content'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: json['createdBy'] ?? '',
    );
  }
}
