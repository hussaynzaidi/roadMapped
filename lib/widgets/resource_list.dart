import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resource.dart';
import '../repositories/resource_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceList extends StatelessWidget {
  final List<String> resourceIds;

  const ResourceList({
    super.key,
    required this.resourceIds,
  });

  @override
  Widget build(BuildContext context) {
    final resourceRepository = context.read<ResourceRepository>();

    return StreamBuilder<List<Resource>>(
      stream: resourceRepository.getResourcesByIds(resourceIds),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading resources');
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final resources = snapshot.data!;
        return Column(
          children: resources.map((resource) {
            return ListTile(
              leading: Icon(_getIconForType(resource.type)),
              title: Text(resource.title),
              subtitle: resource.description != null
                  ? Text(
                      resource.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: resource.isPaid
                  ? const Icon(Icons.attach_money, size: 16)
                  : null,
              onTap: () => _launchUrl(resource.url),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _getIconForType(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return Icons.article;
      case ResourceType.video:
        return Icons.video_library;
      case ResourceType.course:
        return Icons.school;
      case ResourceType.book:
        return Icons.book;
      case ResourceType.other:
        return Icons.link;
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
} 