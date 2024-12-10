import 'package:flutter/material.dart';
import '../models/resource.dart';

class ResourceContentDialog extends StatelessWidget {
  final Resource resource;

  const ResourceContentDialog({
    super.key,
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(resource.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.description.isNotEmpty) ...[
              Text(
                resource.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(),
            ],
            Text(
              resource.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
