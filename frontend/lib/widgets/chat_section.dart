import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'message_bubble.dart';
import 'expense_modal.dart';

class ChatSection extends StatefulWidget {
  const ChatSection({super.key});

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Scroll to bottom when messages change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      appState.messages.length + (appState.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == appState.messages.length) {
                      // Loading indicator
                      return _buildLoadingBubble();
                    }

                    final message = appState.messages[index];
                    return MessageBubble(
                      message: message,
                      onExpenseAction: (action, data) =>
                          _handleExpenseAction(action, data, appState),
                    );
                  },
                ),
              ),
            ),
            _buildConnectionStatus(appState),
            _buildInputSection(appState),
          ],
        );
      },
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 60),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('AI is thinking'),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(AppState appState) {
    if (appState.connectionStatus == ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    String message;
    Color color;
    IconData icon;

    switch (appState.connectionStatus) {
      case ConnectionStatus.noApiKey:
        message =
            'To use this app, you need to set up your Gemini API key in the backend.';
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case ConnectionStatus.disconnected:
        message =
            'Backend server is not running. Please start it with: cd backend && python main.py';
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(AppState appState) {
    final isDisabled =
        appState.isLoading ||
        appState.connectionStatus == ConnectionStatus.disconnected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !isDisabled,
                  decoration: InputDecoration(
                    hintText:
                        'Ask about student budgeting, investments, or track expenses...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: !isDisabled
                      ? (_) => _sendMessage(appState)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed:
                    !isDisabled && _messageController.text.trim().isNotEmpty
                    ? () => _sendMessage(appState)
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: Icon(
                  appState.isLoading ? Icons.hourglass_empty : Icons.send,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildQuickSuggestions(appState),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions(AppState appState) {
    final suggestions = [
      "I spent ₹150 on books and ₹80 on snacks today",
      "How can I save money as a student?",
      "Explain SIP in simple terms",
    ];

    return Wrap(
      spacing: 8,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(suggestion),
          onPressed: appState.isLoading
              ? null
              : () {
                  _messageController.text = suggestion;
                  _sendMessage(appState);
                },
        );
      }).toList(),
    );
  }

  void _sendMessage(AppState appState) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      appState.sendMessage(message);
      _messageController.clear();
    }
  }

  void _handleExpenseAction(String action, dynamic data, AppState appState) {
    switch (action) {
      case 'download_excel':
        // Handle Excel download
        appState.addTokens(10);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel download started! +10 tokens')),
        );
        break;
      case 'download_csv':
        // Handle CSV download
        appState.addTokens(5);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV download started! +5 tokens')),
        );
        break;
      case 'view_summary':
        // Show expense modal
        showDialog(
          context: context,
          builder: (context) => ExpenseModal(data: data),
        );
        break;
    }
  }
}
