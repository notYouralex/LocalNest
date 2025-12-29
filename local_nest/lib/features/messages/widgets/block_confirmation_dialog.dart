import 'package:flutter/material.dart';

/// Dialog for blocking a user
class BlockConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const BlockConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Block User'),
      content: const Text(
        'Are you sure you want to block this user? '
        'You won\'t be able to message them again.',
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Block'),
        ),
      ],
    );
  }
}
