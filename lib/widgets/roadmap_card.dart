import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../models/roadmap.dart';
import '../screens/roadmap/roadmap_detail.dart';

class RoadmapCard extends StatelessWidget {
  final Roadmap roadmap;
=======

class RoadmapCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
  final bool isListView;

  const RoadmapCard({
    super.key,
<<<<<<< HEAD
    required this.roadmap,
=======
    required this.title,
    required this.description,
    required this.progress,
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
<<<<<<< HEAD
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoadmapDetailScreen(roadmap: roadmap),
            ),
          );
=======
          // TODO: Navigate to roadmap detail screen
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
<<<<<<< HEAD
                roadmap.title,
=======
                title,
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: isListView ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
<<<<<<< HEAD
                roadmap.description,
=======
                description,
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: isListView ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              LinearProgressIndicator(
<<<<<<< HEAD
                value: roadmap.progress,
=======
                value: progress,
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
<<<<<<< HEAD
                    '${(roadmap.progress * 100).toInt()}% Complete',
=======
                    '${(progress * 100).toInt()}% Complete',
>>>>>>> 41e31c532534bbc91aa9847c0256e008a7e7c676
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
