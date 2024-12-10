import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/roadmap.dart';
import '../repositories/resource_repository.dart';
import '../widgets/resource_list.dart';
import 'resource_dialog.dart';
import 'package:uuid/uuid.dart';

class StepDialog extends StatefulWidget {
  final Future<void> Function(RoadmapStep) onSave;
  final RoadmapStep? initialStep;

  const StepDialog({
    super.key,
    required this.onSave,
    this.initialStep,
  });

  @override
  State<StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<StepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _resources = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialStep != null) {
      _titleController.text = widget.initialStep!.title;
      _descriptionController.text = widget.initialStep!.description;
      _resources.addAll(widget.initialStep!.resources);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addResource() {
    showDialog(
      context: context,
      builder: (context) => ResourceDialog(
        onSave: (resource) async {
          final resourceRepository = context.read<ResourceRepository>();
          try {
            final resourceId = await resourceRepository.create(resource);
            if (mounted) {
              setState(() {
                _resources.add(resourceId);
              });
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving resource: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final step = RoadmapStep(
      id: widget.initialStep?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      resources: _resources,
      isCompleted: widget.initialStep?.isCompleted ?? false,
    );
    await widget.onSave(step);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialStep == null ? 'Add Step' : 'Edit Step'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resources (${_resources.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addResource,
                    tooltip: 'Add Resource',
                  ),
                ],
              ),
              if (_resources.isNotEmpty) ...[
                const SizedBox(height: 8),
                ResourceList(
                  resourceIds: _resources,
                  showInDialog: true,
                )
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
