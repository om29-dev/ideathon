import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'message_bubble.dart';
import 'expense_modal.dart';
import '../src/download_helper.dart';

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
            _buildChatHeader(appState),
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

  Widget _buildChatHeader(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AI Chat (${appState.messages.length} messages)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (appState.messages.length >
              1) // Don't show if only welcome message
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => _showClearChatDialog(appState),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _showDeleteAllChatsDialog(appState),
                  icon: const Icon(Icons.delete_forever, size: 18),
                  label: const Text('Delete All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showClearChatDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
          'Are you sure you want to clear all chat messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              appState.clearChatHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat history cleared successfully!'),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllChatsDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Chat History'),
        content: const Text(
          'Are you sure you want to permanently delete all chat messages from the database? This action cannot be undone and will remove all your conversation history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await appState.clearChatHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All chat history permanently deleted!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(AppState appState) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      appState.sendMessage(message);
      _messageController.clear();
    }
  }

  void _handleExpenseAction(
    String action,
    dynamic data,
    AppState appState,
  ) async {
    switch (action) {
      case 'download_excel':
        await _downloadFile('excel', data, appState);
        break;
      case 'download_csv':
        await _downloadFile('csv', data, appState);
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

  Future<void> _downloadFile(
    String format,
    dynamic data,
    AppState appState,
  ) async {
    try {
      // Convert the expense data to the appropriate format
      String content = '';
      String filename = '';

      if (data != null && data is Map<String, dynamic>) {
        if (format == 'excel') {
          // For Excel, we'll create a simple CSV that can be opened in Excel
          content = _convertToCSV(data);
          filename = 'expenses.csv';
        } else {
          content = _convertToCSV(data);
          filename = 'expenses.csv';
        }

        // Convert string to bytes
        final bytes = utf8.encode(content);

        // Download the file
        await downloadBytes(bytes, filename);

        // Add tokens and show success message
        final tokens = format == 'excel' ? 10 : 5;
        appState.addTokens(tokens);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${format.toUpperCase()} downloaded successfully! +$tokens tokens',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No expense data available to download'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
      }
    }
  }

  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Add header
    buffer.writeln('Date,Category,Description,Amount');

    // Add data rows
    if (data['expenses'] != null && data['expenses'] is List) {
      for (final expense in data['expenses']) {
        final date = expense['date'] ?? '';
        final category = expense['category'] ?? '';
        final description = expense['description'] ?? '';
        final amount = expense['amount'] ?? 0;

        buffer.writeln('$date,$category,$description,$amount');
      }
    }

    return buffer.toString();
  }
}
