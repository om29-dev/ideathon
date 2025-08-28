import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/theme_notifier.dart';
import '../services/notification_service.dart';

class AppDrawer extends StatefulWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const AppDrawer({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _dailyTipEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService.isDailyNotificationsEnabled();
    if (mounted) {
      setState(() {
        _dailyTipEnabled = enabled;
      });
    }
  }

  Future<void> _setDailyTipEnabled(bool enabled) async {
    if (enabled) {
      await NotificationService.requestPermissions();
      await NotificationService.enableDailyNotifications();
    } else {
      await NotificationService.disableDailyNotifications();
    }
    if (mounted) {
      setState(() {
        _dailyTipEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = context.watch<AppState>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with user profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF4361ee), const Color(0xFF7209b7)]
                      : [const Color(0xFF4361ee), const Color(0xFF4895ef)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Status and tokens row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Connection status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    appState.connectionStatus ==
                                        ConnectionStatus.connected
                                    ? Colors.green
                                    : appState.connectionStatus ==
                                          ConnectionStatus.checking
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              appState.connectionStatus ==
                                      ConnectionStatus.connected
                                  ? 'Online'
                                  : appState.connectionStatus ==
                                        ConnectionStatus.checking
                                  ? 'Checking'
                                  : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tokens
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${appState.userTokens}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name and title
                  const Text(
                    'Student User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Finance Enthusiast',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(icon: Icons.home, title: 'Home', index: 0),
                  _buildNavItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Budget',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.track_changes,
                    title: 'Goals',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    index: 3,
                  ),

                  const Divider(height: 24),

                  // Settings section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // Theme toggle
                  ListTile(
                    leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                    onTap: () {
                      context.read<ThemeNotifier>().toggleTheme();
                      Navigator.pop(context);
                    },
                  ),

                  // Daily notifications
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Daily Tips'),
                    subtitle: const Text('Get daily finance tips'),
                    value: _dailyTipEnabled,
                    onChanged: _setDailyTipEnabled,
                  ),

                  // Test notification (if enabled)
                  if (_dailyTipEnabled)
                    ListTile(
                      leading: const Icon(Icons.notification_add),
                      title: const Text('Test Notification'),
                      onTap: () async {
                        await NotificationService.showTestNotification();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),

                  const Divider(height: 24),

                  // App info
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = widget.currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          widget.onNavigate(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('AI Finance Assistant'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Your personal AI-powered finance companion'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Expense tracking'),
            Text('• Budget management'),
            Text('• Financial goals'),
            Text('• Analytics & insights'),
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
}
