import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../repositories/roadmap_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/step_dialog.dart';
import '../../widgets/step_tile.dart';

/// Screen for creating new roadmaps.
///
/// Allows users to:
/// - Set title and description
/// - Add and manage steps
/// - Configure visibility settings
/// - Add resources to steps
///
/// Uses [RoadmapRepository] for persistence and
/// [AuthService] for user association.
class RoadmapCreateScreen extends StatefulWidget {
  const RoadmapCreateScreen({super.key});

  @override
  State<RoadmapCreateScreen> createState() => _RoadmapCreateScreenState();
}

class _RoadmapCreateScreenState extends State<RoadmapCreateScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controllers for text input fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// List of steps in the roadmap
  final List<RoadmapStep> _steps = [];

  /// Visibility setting for the roadmap
  bool _isPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Shows dialog to add a new step to the roadmap.
  ///
  /// Uses [StepDialog] for input and adds the new step
  /// to [_steps] when saved.
  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => StepDialog(
        onSave: (step) async {
          setState(() {
            _steps.add(step);
          });
        },
      ),
    );
  }

  /// Saves the roadmap to Firestore.
  ///
  /// Process:
  /// 1. Validates form input
  /// 2. Gets current user
  /// 3. Creates Roadmap object
  /// 4. Persists to Firestore
  /// 5. Handles success/error states
  Future<void> _saveRoadmap() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    final roadmap = Roadmap(
      id: '', // Will be set by Firestore
      title: _titleController.text,
      description: _descriptionController.text,
      steps: _steps,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      isPublic: _isPublic,
    );

    try {
      await context.read<RoadmapRepository>().create(roadmap);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating roadmap: $e')),
        );
      }
    }
  }

  /// Validates and saves the current form state.
  ///
  /// Returns true if validation passes, false otherwise.
  /// Used before performing save operations.
  // bool _validateForm() {
  //   return _formKey.currentState?.validate() ?? false;
  // }

  /// Resets the form to its initial state.
  ///
  /// Clears:
  /// - Title and description fields
  /// - Steps list
  /// - Visibility setting
  // void _resetForm() {
  //   _titleController.clear();
  //   _descriptionController.clear();
  //   setState(() {
  //     _steps.clear();
  //     _isPublic = true;
  //   });
  //   _formKey.currentState?.reset();
  // }

  /// Removes a step from the roadmap.
  ///
  /// Parameters:
  /// - [index]: The position of the step to remove
  ///
  /// Updates the UI immediately after removal.
  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Roadmap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoadmap,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Description is required' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Roadmap'),
              subtitle:
                  const Text('Allow others to view and follow this roadmap'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            const SizedBox(height: 16),
            const Text(
              'Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return StepTile(
                step: step,
                onDelete: () =>
                    _removeStep(index), // Attach the delete callback here
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
          ],
        ),
      ),
    );
  }
}
