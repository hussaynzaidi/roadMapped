import 'package:flutter/material.dart';
import '../models/roadmap.dart';
import 'package:uuid/uuid.dart';

class StepDialog extends StatefulWidget {
  final void Function(RoadmapStep) onSave;
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
    // TODO: Implement resource selection dialog
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final step = RoadmapStep(
        id: widget.initialStep?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        resources: _resources,
      );
      widget.onSave(step);
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
              ),
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