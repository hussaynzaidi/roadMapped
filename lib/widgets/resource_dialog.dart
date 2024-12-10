import 'package:flutter/material.dart';
import '../models/resource.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ResourceDialog extends StatefulWidget {
  final Future<void> Function(Resource) onSave;

  const ResourceDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<ResourceDialog> createState() => _ResourceDialogState();
}

class _ResourceDialogState extends State<ResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  ResourceType _selectedType = ResourceType.link;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _validateContent(String? value) {
    if (value?.isEmpty ?? true) return 'Content is required';
    if (_selectedType == ResourceType.link) {
      try {
        final url = Uri.parse(value!);
        if (!url.hasScheme) return 'Invalid URL';
      } catch (e) {
        return 'Invalid URL';
      }
    }
    return null;
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final resource = Resource(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      content: _contentController.text,
      createdAt: DateTime.now(),
      createdBy: authService.currentUser!.uid,
    );

    try {
      await widget.onSave(resource);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving resource: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Resource'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ResourceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(),
                ),
                items: ResourceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _contentController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
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
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText:
                      _selectedType == ResourceType.link ? 'URL' : 'Content',
                  border: const OutlineInputBorder(),
                ),
                maxLines: _selectedType == ResourceType.text ? 3 : 1,
                validator: _validateContent,
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
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
