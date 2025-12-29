import 'package:flutter/material.dart';
import '../models/models.dart';

class MessageOptionsBottomSheet extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MessageOptionsBottomSheet({
    super.key,
    required this.message,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Message Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: onDelete,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
