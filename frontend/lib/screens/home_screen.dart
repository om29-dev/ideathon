import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/theme_notifier.dart';
import '../widgets/chat_section.dart';
import '../widgets/profile_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 200) {
                  // Very small screens - just show emoji
                  return const Text('🤖', style: TextStyle(fontSize: 24));
                } else if (constraints.maxWidth < 300) {
                  // Small screens - short title
                  return const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 4),
                      Text(
                        'Finance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  // Full title for larger screens
                  return const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'AI Finance Assistant',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            actions: [
              _buildStatusBadge(appState.connectionStatus),
              const SizedBox(width: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (MediaQuery.of(context).size.width < 400) {
                    // Small screen - icon only
                    return Consumer<ThemeNotifier>(
                      builder: (context, themeNotifier, child) {
                        return IconButton(
                          onPressed: () => themeNotifier.toggleTheme(),
                          icon: Text(
                            themeNotifier.themeMode == ThemeMode.dark
                                ? '🌙'
                                : '☀️',
                            style: const TextStyle(fontSize: 20),
                          ),
                          tooltip: 'Toggle Theme',
                        );
                      },
                    );
                  } else {
                    // Larger screen - icon with label
                    return Consumer<ThemeNotifier>(
                      builder: (context, themeNotifier, child) {
                        return ElevatedButton.icon(
                          onPressed: () => themeNotifier.toggleTheme(),
                          icon: Text(
                            themeNotifier.themeMode == ThemeMode.dark
                                ? '🌙'
                                : '☀️',
                            style: const TextStyle(fontSize: 16),
                          ),
                          label: const Text('Theme'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 768) {
                // Desktop layout
                return Row(
                  children: [
                    SizedBox(width: 300, child: ProfileSection()),
                    Expanded(child: ChatSection()),
                  ],
                );
              } else {
                // Mobile layout
                return ChatSection();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ConnectionStatus status) {
    Color color;
    String text;
    String shortText;
    IconData icon;

    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        text = 'Connected';
        shortText = 'OK';
        icon = Icons.check_circle;
        break;
      case ConnectionStatus.noApiKey:
        color = Colors.orange;
        text = 'API Key Required';
        shortText = 'API';
        icon = Icons.warning;
        break;
      case ConnectionStatus.disconnected:
        color = Colors.red;
        text = 'Backend Offline';
        shortText = 'OFF';
        icon = Icons.error;
        break;
      case ConnectionStatus.checking:
        color = Colors.grey;
        text = 'Checking...';
        shortText = '...';
        icon = Icons.refresh;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = MediaQuery.of(context).size.width < 400;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 4 : 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              if (!isSmallScreen) ...[
                const SizedBox(width: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 2),
                Text(
                  shortText,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
