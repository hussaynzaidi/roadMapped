import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/roadmap.dart';
import '../../repositories/roadmap_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/step_dialog.dart';
import '../../widgets/step_tile.dart';

class RoadmapCreateScreen extends StatefulWidget {
  const RoadmapCreateScreen({super.key});

  @override
  State<RoadmapCreateScreen> createState() => _RoadmapCreateScreenState();
}

class _RoadmapCreateScreenState extends State<RoadmapCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<RoadmapStep> _steps = [];
  bool _isPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => StepDialog(
        onSave: (step) {
          setState(() {
            _steps.add(step);
          });
        },
      ),
    );
  }

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
              subtitle: const Text('Allow others to view and follow this roadmap'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            const SizedBox(height: 16),
            const Text(
              'Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._steps.map((step) => StepTile(
                  step: step,
                  onDelete: () =>
                      setState(() => _steps.remove(step)),
                )),
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