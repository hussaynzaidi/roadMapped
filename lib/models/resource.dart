import 'package:cloud_firestore/cloud_firestore.dart';

enum ResourceType {
  video,
  article,
  book,
  course,
  other
}

class Resource {
  final String id;
  final String title;
  final String description;
  final String url;
  final ResourceType type;
  final String addedBy;
  final DateTime addedAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    required this.addedBy,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'type': type.toString().split('.').last,
      'addedBy': addedBy,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      type: ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      addedBy: json['addedBy'] as String,
      addedAt: (json['addedAt'] as Timestamp).toDate(),
    );
  }
}
