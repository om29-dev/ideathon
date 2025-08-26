import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
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
            title: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                const Text(
                  'AI Finance Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              _buildStatusBadge(appState.connectionStatus),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => appState.cycleTheme(),
                icon: Text(
                  appState.getThemeIcon(),
                  style: const TextStyle(fontSize: 16),
                ),
                label: const Text('Theme'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 16),
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
    IconData icon;

    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        text = 'Connected';
        icon = Icons.check_circle;
        break;
      case ConnectionStatus.noApiKey:
        color = Colors.orange;
        text = 'API Key Required';
        icon = Icons.warning;
        break;
      case ConnectionStatus.disconnected:
        color = Colors.red;
        text = 'Backend Offline';
        icon = Icons.error;
        break;
      case ConnectionStatus.checking:
        color = Colors.grey;
        text = 'Checking...';
        icon = Icons.refresh;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
