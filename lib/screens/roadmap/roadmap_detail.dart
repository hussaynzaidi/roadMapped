import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../models/progress.dart';
import '../../repositories/progress_repository.dart';
import '../../repositories/resource_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/resource_list.dart';

class RoadmapDetailScreen extends StatefulWidget {
  final Roadmap roadmap;

  const RoadmapDetailScreen({super.key, required this.roadmap});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  late final ProgressRepository _progressRepository;
  late final ResourceRepository _resourceRepository;
  late final Stream<RoadmapProgress?> _progressStream;

  @override
  void initState() {
    super.initState();
    _progressRepository = context.read<ProgressRepository>();
    _resourceRepository = context.read<ResourceRepository>();
    final userId = context.read<AuthService>().currentUser?.uid;
    
    if (userId != null) {
      _progressStream = _progressRepository.getUserRoadmapProgress(
        userId,
        widget.roadmap.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roadmap.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.roadmap.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            StreamBuilder<RoadmapProgress?>(
              stream: _progressStream,
              builder: (context, snapshot) {
                final progress = snapshot.data;
                return Column(
                  children: widget.roadmap.steps.map((step) {
                    final isCompleted = progress?.completedSteps[step.id] ?? false;
                    return _StepCard(
                      step: step,
                      isCompleted: isCompleted,
                      onToggleComplete: (completed) {
                        if (progress != null) {
                          _progressRepository.updateStepCompletion(
                            progress.id,
                            step.id,
                            completed,
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final RoadmapStep step;
  final bool isCompleted;
  final ValueChanged<bool> onToggleComplete;

  const _StepCard({
    required this.step,
    required this.isCompleted,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) => onToggleComplete(value ?? false),
                ),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (step.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(step.description),
            ],
            if (step.resources.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Resources:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ResourceList(resourceIds: step.resources),
            ],
          ],
        ),
      ),
    );
  }
}
