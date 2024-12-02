import 'package:flutter/material.dart';
import '../models/roadmap.dart';

class StepTile extends StatelessWidget {
  final RoadmapStep step;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const StepTile({
    super.key,
    required this.step,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(step.title),
        subtitle: Text(
          step.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
} 