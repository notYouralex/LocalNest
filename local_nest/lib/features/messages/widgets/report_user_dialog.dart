import 'package:flutter/material.dart';

/// Dialog for reporting a user
class ReportUserDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(String reason) onSubmit;

  const ReportUserDialog({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  late TextEditingController _reportController;

  @override
  void initState() {
    super.initState();
    _reportController = TextEditingController();
  }

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Why are you reporting this user?'),
          const SizedBox(height: 16),
          TextField(
            controller: _reportController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Provide details...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(_reportController.text);
          },
          child: const Text('Report'),
        ),
      ],
    );
  }
}
