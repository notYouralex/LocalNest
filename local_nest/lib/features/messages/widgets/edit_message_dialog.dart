import 'package:flutter/material.dart';
import '../models/models.dart';
import '../constants/messages_constants.dart';

/// Dialog for editing a message
class EditMessageDialog extends StatefulWidget {
  final MessageModel message;
  final VoidCallback onCancel;
  final Function(String newContent) onSave;

  const EditMessageDialog({
    super.key,
    required this.message,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: _editController,
        maxLines: null,
        maxLength: MessagesConstants.maxMessageLength,
        decoration: const InputDecoration(
          hintText: 'Edit your message...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newContent = _editController.text.trim();
            if (newContent.isNotEmpty &&
                newContent.length <= MessagesConstants.maxMessageLength) {
              widget.onSave(newContent);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
