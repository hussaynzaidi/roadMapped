import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../repositories/resource_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/resource_content_dialog.dart';

class ResourceList extends StatelessWidget {
  final List<String> resourceIds;
  final bool showInDialog;

  const ResourceList({
    super.key,
    required this.resourceIds,
    this.showInDialog = false,
  });

  Future<void> _openResource(BuildContext context, Resource resource) async {
    switch (resource.type) {
      case ResourceType.link:
        final url = Uri.parse(resource.content);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open URL')),
            );
          }
        }
        break;
      case ResourceType.text:
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => ResourceContentDialog(resource: resource),
          );
        }
        break;
    }
  }

  Widget _buildResourceTile(Resource resource, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          resource.type == ResourceType.link ? Icons.link : Icons.description,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          resource.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resource.description),
            if (resource.type == ResourceType.link)
              Text(
                resource.content,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => _openResource(context, resource),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resourceRepository = context.read<ResourceRepository>();

    if (resourceIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Resource>>(
      stream: resourceRepository.getResourcesByIds(resourceIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final resources = snapshot.data ?? [];

        if (showInDialog) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: resources
                .map((resource) => _buildResourceTile(resource, context))
                .toList(),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return _buildResourceTile(resource, context);
          },
        );
      },
    );
  }
}
