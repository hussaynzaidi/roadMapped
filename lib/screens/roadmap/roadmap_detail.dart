import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../models/progress.dart';
import '../../repositories/progress_repository.dart';
import '../../repositories/resource_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/resource_list.dart';

/// Displays detailed view of a roadmap and handles progress tracking.
///
/// Features:
/// - Progress visualization
/// - Step completion toggling
/// - Resource viewing
/// - Progress reset functionality
///
/// Uses [ProgressRepository] for real-time progress tracking and
/// [ResourceRepository] for managing step resources.
class RoadmapDetailScreen extends StatefulWidget {
  final Roadmap roadmap;

  const RoadmapDetailScreen({super.key, required this.roadmap});

  @override
  State<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends State<RoadmapDetailScreen> {
  late final ProgressRepository _progressRepository;
  // late final ResourceRepository _resourceRepository;
  late final Stream<RoadmapProgress?> _progressStream;
  String? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progressRepository = context.read<ProgressRepository>();
    //  _resourceRepository = context.read<ResourceRepository>();
    _userId = context.read<AuthService>().currentUser?.uid;

    if (_userId != null) {
      _progressStream = _progressRepository.getUserRoadmapProgress(
          _userId!, widget.roadmap.id);
    }
  }

  /// Toggles the completion status of a step.
  ///
  /// Parameters:
  /// - [progressId]: ID of the progress record
  /// - [stepId]: ID of the step to toggle
  /// - [currentValue]: Current completion status
  ///
  /// Shows error message if update fails.
  Future<void> _toggleStepCompletion(
      String progressId, String stepId, bool currentValue) async {
    try {
      await _progressRepository.updateStepCompletion(
          progressId, stepId, !currentValue, widget.roadmap.steps.length);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating progress: $e')),
        );
      }
    }
  }

  /// Starts or restarts progress tracking for the roadmap.
  ///
  /// Process:
  /// 1. Deletes any existing progress
  /// 2. Waits for deletion to process
  /// 3. Creates new progress record
  ///
  /// Shows error message if operation fails.
  Future<void> _startRoadmap() async {
    if (_userId == null) return;

    try {
      // Delete the old progress first
      final currentProgress = await _progressRepository
          .getUserRoadmapProgress(_userId!, widget.roadmap.id)
          .first;

      if (currentProgress != null) {
        await _progressRepository.delete(currentProgress.id);
      }

      // Wait a moment to ensure deletion is processed
      await Future.delayed(const Duration(milliseconds: 100));

      // Create new progress
      final progress = RoadmapProgress(
        id: '',
        userId: _userId!,
        roadmapId: widget.roadmap.id,
        completedSteps: {},
        startedAt: DateTime.now(),
        progressPercentage: 0,
      );

      // Create and wait for completion
      await _progressRepository.create(progress);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting roadmap: $e')),
        );
      }
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
              final roadmapLink = 'roadmapped://roadmap/${widget.roadmap.id}';
              // Show share dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Share Roadmap'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SelectableText(roadmapLink),
                      const SizedBox(height: 16),
                      const Text('Copy this link to share the roadmap'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: roadmapLink));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Link copied to clipboard')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Copy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _userId == null
          ? const Center(child: Text('Sign in to track progress'))
          : StreamBuilder<RoadmapProgress?>(
              stream: _progressStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final progress = snapshot.data;
                final progressValue = progress?.progressPercentage ?? 0.0;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.roadmap.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              if (progress == null) ...[
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Show loading state during the operation
                                      setState(() => _isLoading = true);
                                      await _startRoadmap();
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    },
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Start This Roadmap'),
                                  ),
                                ),
                              ] else ...[
                                if (progressValue >= 1.0) ...[
                                  const Icon(Icons.celebration,
                                      size: 48, color: Colors.amber),
                                  const Text(
                                    'Congratulations! 🎉',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            setState(() => _isLoading = true);
                                            await _startRoadmap();
                                            if (mounted) {
                                              setState(
                                                  () => _isLoading = false);
                                            }
                                          },
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Start Again'),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: progressValue,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(progressValue * 100).toInt()}% Complete',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (progress != null && progressValue < 1.0)
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.roadmap.steps.length,
                              itemBuilder: (context, index) {
                                final step = widget.roadmap.steps[index];
                                final isCompleted =
                                    progress.completedSteps[step.id] ?? false;

                                return ExpansionTile(
                                  leading: Checkbox(
                                    value: isCompleted,
                                    onChanged: (bool? value) {
                                      _toggleStepCompletion(
                                        progress.id,
                                        step.id,
                                        isCompleted,
                                      );
                                    },
                                  ),
                                  title: Text(
                                    step.title,
                                    style: TextStyle(
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Text(step.description),
                                  children: [
                                    ResourceList(resourceIds: step.resources),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
