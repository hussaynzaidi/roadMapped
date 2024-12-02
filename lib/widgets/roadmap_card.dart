import 'package:flutter/material.dart';

class RoadmapCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final bool isListView;

  const RoadmapCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to roadmap detail screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: isListView ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: isListView ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!isListView)
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // TODO: Show options menu
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
