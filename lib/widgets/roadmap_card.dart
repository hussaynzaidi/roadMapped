import 'package:flutter/material.dart';
import '../models/roadmap.dart';
import '../screens/roadmap/roadmap_detail.dart';

class RoadmapCard extends StatelessWidget {
  final Roadmap roadmap;
  final bool isListView;

  const RoadmapCard({
    super.key,
    required this.roadmap,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoadmapDetailScreen(roadmap: roadmap),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roadmap.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: isListView ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                roadmap.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: isListView ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: roadmap.progress,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(roadmap.progress * 100).toInt()}% Complete',
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
