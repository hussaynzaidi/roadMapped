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
  late final Stream<RoadmapProgress?> _progressStream;
  String? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progressRepository = context.read<ProgressRepository>();
    _userId = context.read<AuthService>().currentUser?.uid;

    if (_userId != null) {
      _progressStream = _progressRepository.getUserRoadmapProgress(
        _userId!,
        widget.roadmap.id,
      );
    }
  }

  Future<void> _handleError(String operation, dynamic error) async {
    final message = switch (error.toString()) {
      String msg when msg.contains('permission-denied') =>
        'You don\'t have permission to $operation this roadmap',
      String msg when msg.contains('not-found') =>
        'This roadmap no longer exists',
      String msg when msg.contains('network') =>
        'Network error. Please check your connection',
      _ => 'Error while $operation: ${error.toString()}'
    };

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: error.toString().contains('network')
              ? SnackBarAction(
                  label: 'Retry',
                  onPressed: () => _startRoadmap(),
                )
              : null,
        ),
      );
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
      await _handleError('updating', e);
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
      setState(() => _isLoading = true);

      final currentProgress = await _progressRepository
          .getUserRoadmapProgress(_userId!, widget.roadmap.id)
          .first;

      if (currentProgress != null) {
        await _progressRepository.delete(currentProgress.id);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final progress = RoadmapProgress(
        id: '',
        userId: _userId!,
        roadmapId: widget.roadmap.id,
        completedSteps: {},
        startedAt: DateTime.now(),
        progressPercentage: 0,
      );

      await _progressRepository.create(progress);
    } catch (e) {
      await _handleError('starting', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showShareDialog(BuildContext context) {
    final roadmapLink = 'roadmapped://roadmap/${widget.roadmap.id}';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Roadmap'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  roadmapLink,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Copy this link to share the roadmap'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: roadmapLink));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(widget.roadmap.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareDialog(context),
          ),
        ],
      ),
      body: _userId == null
          ? Center(
              child: Text(
                'Sign in to track progress',
                style: theme.textTheme.titleMedium,
              ),
            )
          : StreamBuilder<RoadmapProgress?>(
              stream: _progressStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final progress = snapshot.data;
                final progressValue = progress?.progressPercentage ?? 0.0;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.roadmap.description,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            if (progress == null)
                              Center(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
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
                            if (progress != null) ...[
                              if (progressValue >= 1.0) ...[
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.celebration,
                                          size: 48, color: Colors.amber),
                                      const Text(
                                        'Congratulations! 🎉',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'This roadmap is complete. You can start again below.',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () async {
                                                setState(
                                                    () => _isLoading = true);
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
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text('Start Again'),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                LinearProgressIndicator(
                                  value: progressValue,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainer,
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(progressValue * 100).toInt()}% Complete',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (progress != null && progressValue < 1.0)
                      ...widget.roadmap.steps.map((step) {
                        final isCompleted =
                            progress.completedSteps[step.id] ?? false;
                        return Card(
                          margin: const EdgeInsets.only(top: 8),
                          child: ExpansionTile(
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
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
    );
  }
}
