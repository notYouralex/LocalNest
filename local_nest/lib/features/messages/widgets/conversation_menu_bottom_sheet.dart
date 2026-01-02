import 'package:flutter/material.dart';

class ConversationMenuBottomSheet extends StatelessWidget {
  final VoidCallback onBlock;
  final VoidCallback onReport;

  const ConversationMenuBottomSheet({
    super.key,
    required this.onBlock,
    required this.onReport,
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
              'More Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.orange),
            title: const Text('Block User', style: TextStyle(color: Colors.orange)),
            onTap: onBlock,
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.red),
            title: const Text('Report User', style: TextStyle(color: Colors.red)),
            onTap: onReport,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
