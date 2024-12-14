import 'package:flutter/material.dart';
import '../models/roadmap.dart';
import '../models/progress.dart';
import '../repositories/progress_repository.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// A card widget displaying roadmap information and progress.
///
/// Features:
/// - Title and description display
/// - Progress indicator
/// - Completion percentage
/// - Responsive layout support
///
/// Adapts its layout based on [isListView] parameter.
class RoadmapCard extends StatelessWidget {
  final Roadmap roadmap;
  final bool isListView;
  final VoidCallback? onTap;

  const RoadmapCard({
    super.key,
    required this.roadmap,
    this.isListView = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.uid;
    final progressRepository = context.read<ProgressRepository>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roadmap.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                roadmap.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: isListView ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              if (userId != null)
                StreamBuilder<RoadmapProgress?>(
                  stream: progressRepository.getUserRoadmapProgress(
                      userId, roadmap.id),
                  builder: (context, snapshot) {
                    final progress = snapshot.data?.progressPercentage ?? 0.0;
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}% Complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
