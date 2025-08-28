import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/navigation_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final VoidCallback? onProfileTap;
  final bool showBackButton;
  final bool showThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.onProfileTap,
    this.showBackButton = false,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: showThemeToggle
          ? Row(
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
            )
          : null,
      actions: showThemeToggle
          ? [
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.read<ThemeNotifier>().toggleTheme();
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
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: onProfileTap ?? () => _showDefaultProfile(context),
                tooltip: 'Profile',
              ),
              if (additionalActions != null) ...additionalActions!,
            ]
          : null,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  void _showDefaultProfile(BuildContext context) {
    // Navigate to profile screen using navigation state (Profile is index 7)
    context.read<NavigationState>().setIndex(7);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
