import 'package:flutter/material.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const NotificationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.notifications_active,
        size: 48,
        color: Colors.blue,
      ),
      title: const Text('Enable Daily Finance Tips?'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get personalized finance tips delivered to your phone every day at 9:00 AM.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '💡 Smart AI tips\n📅 Daily at 9 AM\n💰 Improve your savings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onDeny, child: const Text('Not Now')),
        ElevatedButton(
          onPressed: onAllow,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Allow Notifications'),
        ),
      ],
    );
  }
}
