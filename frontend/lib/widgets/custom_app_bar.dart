import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.onToggleTheme,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Additional actions passed from specific screens
        if (additionalActions != null) ...additionalActions!,

        // Theme toggle button
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () {
            onToggleTheme?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Theme.of(context).brightness == Brightness.dark
                      ? '☀️ Switched to Light Mode!'
                      : '🌙 Switched to Dark Mode!',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'Toggle Theme',
        ),

        // Profile button
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: onProfileTap ?? () => _showDefaultProfile(context),
          tooltip: 'Profile',
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  void _showDefaultProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('Profile'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: Finance Student'),
            SizedBox(height: 8),
            Text('App Version: 1.0.0'),
            SizedBox(height: 8),
            Text('© 2025 AI Finance Assistant'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
