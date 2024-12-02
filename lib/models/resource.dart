enum ResourceType { article, video, course, book, other }

class Resource {
  final String id;
  final String title;
  final String url;
  final ResourceType type;
  final String? description;
  final bool isPaid;
  final String? thumbnailUrl;
  final Duration? estimatedTime;
  final List<String> tags;

  Resource({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.description,
    this.isPaid = false,
    this.thumbnailUrl,
    this.estimatedTime,
    this.tags = const [],
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      type: ResourceType.values.firstWhere(
        (e) => e.toString() == 'ResourceType.${json['type']}',
        orElse: () => ResourceType.other,
      ),
      description: json['description'],
      isPaid: json['isPaid'] ?? false,
      thumbnailUrl: json['thumbnailUrl'],
      estimatedTime: json['estimatedTime'] != null
          ? Duration(minutes: json['estimatedTime'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'type': type.toString().split('.').last,
        'description': description,
        'isPaid': isPaid,
        'thumbnailUrl': thumbnailUrl,
        'estimatedTime': estimatedTime?.inMinutes,
        'tags': tags,
      };
}
