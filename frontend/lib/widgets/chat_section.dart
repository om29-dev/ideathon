import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/message.dart';
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
              color: Colors.black.withValues(alpha: 0.1),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: MediaQuery.of(context).size.width > 600 ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 600
                  ? 800
                  : double.infinity,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !isDisabled,
                    decoration: InputDecoration(
                      hintText:
                          'Ask about student budgeting, investments, or track expenses...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width > 600
                            ? 24
                            : 20,
                        vertical: MediaQuery.of(context).size.width > 600
                            ? 20
                            : 16,
                      ),
                    ),
                    onSubmitted: !isDisabled
                        ? (_) => _sendMessage(appState)
                        : null,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 600 ? 16 : 12,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 600 ? 64 : 56,
                  height: MediaQuery.of(context).size.width > 600 ? 64 : 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed:
                          !isDisabled &&
                              _messageController.text.trim().isNotEmpty
                          ? () => _sendMessage(appState)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width > 600 ? 64 : 56,
                          MediaQuery.of(context).size.width > 600 ? 64 : 56,
                        ),
                      ),
                      child: Icon(
                        appState.isLoading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width > 600 ? 28 : 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
    final hasExpenseMessages = appState.messages.any(
      (message) => message.hasExpenses,
    );

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
          Expanded(
            child: Text(
              'AI Chat (${appState.messages.length} messages)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show export button if there are any expense messages
              if (hasExpenseMessages) ...[
                ElevatedButton.icon(
                  onPressed: () => _exportAllExpenses(appState),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Add sample expense button for testing
              if (!hasExpenseMessages) ...[
                ElevatedButton.icon(
                  onPressed: () => _addSampleExpense(appState),
                  icon: const Icon(Icons.add_card, size: 18),
                  label: const Text('Try Sample'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (appState.messages.length > 1) ...[
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
            ],
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.refresh, color: Colors.orange),
              SizedBox(width: 8),
              Text('Clear Chat'),
            ],
          ),
          content: const Text(
            'Are you sure you want to clear all messages? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.clearMessages();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Chat cleared!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _exportAllExpenses(AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.download, color: Colors.green),
              SizedBox(width: 8),
              Text('Export Expenses'),
            ],
          ),
          content: const Text(
            'Choose export format for all detected expenses:',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _exportCombinedExpenses(appState, 'csv');
              },
              icon: const Icon(Icons.table_chart, size: 16),
              label: const Text('CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _exportCombinedExpenses(appState, 'excel');
              },
              icon: const Icon(Icons.description, size: 16),
              label: const Text('Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportCombinedExpenses(AppState appState, String format) async {
    try {
      // Collect all expense data from messages
      final allExpenses = <Map<String, dynamic>>[];

      for (final message in appState.messages) {
        if (message.hasExpenses && message.excelData != null) {
          final expenseData = message.excelData!;
          if (expenseData['expenses'] is List) {
            allExpenses.addAll(
              List<Map<String, dynamic>>.from(expenseData['expenses']),
            );
          }
        }
      }

      if (allExpenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No expenses found to export')),
        );
        return;
      }

      // Create combined expense data
      final combinedData = {
        'expenses': allExpenses,
        'total': allExpenses.fold<double>(
          0,
          (sum, expense) => sum + (expense['amount'] ?? 0),
        ),
        'count': allExpenses.length,
      };

      await _downloadFile(format, combinedData, appState);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  void _showDeleteAllChatsDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete All Chat History'),
          ],
        ),
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

  void _addSampleExpense(AppState appState) {
    // Add a sample expense message to demonstrate the export functionality
    final sampleExpenseData = {
      'expenses': [
        {
          'date': '2025-08-28',
          'description': 'Lunch at Restaurant',
          'amount': 450.0,
          'category': 'Food & Dining',
        },
        {
          'date': '2025-08-28',
          'description': 'Uber ride',
          'amount': 120.0,
          'category': 'Transportation',
        },
        {
          'date': '2025-08-27',
          'description': 'Grocery shopping',
          'amount': 800.0,
          'category': 'Food & Dining',
        },
      ],
      'total': 1370.0,
      'count': 3,
    };

    final sampleMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      text:
          '📊 **Sample Expense Analysis**\n\nI found 3 expenses in your sample data:\n\n• 🍽️ **Lunch at Restaurant** - ₹450 (Food & Dining)\n• 🚗 **Uber ride** - ₹120 (Transportation)\n• 🛒 **Grocery shopping** - ₹800 (Food & Dining)\n\n**Total Amount:** ₹1,370\n\nUse the buttons below to download your expense report!',
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      hasExpenses: true,
      excelData: sampleExpenseData,
    );

    appState.addMessage(sampleMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample expenses added! Try the export buttons below.'),
        backgroundColor: Colors.green,
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
