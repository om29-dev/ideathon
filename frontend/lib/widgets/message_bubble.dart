import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String, dynamic)? onExpenseAction;

  const MessageBubble({super.key, required this.message, this.onExpenseAction});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isError = message.sender == MessageSender.error;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBubbleColor(context, isUser, isError),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageContent(context),
            if (message.hasExpenses && message.excelData != null)
              _buildExpenseActions(context),
            const SizedBox(height: 8),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: _getTextColor(context, isUser, isError).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBubbleColor(BuildContext context, bool isUser, bool isError) {
    if (isError) {
      return Colors.red.withOpacity(0.1);
    }
    if (isUser) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).cardColor;
  }

  Color _getTextColor(BuildContext context, bool isUser, bool isError) {
    if (isError) {
      return Colors.red;
    }
    if (isUser) {
      return Colors.white;
    }
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  Widget _buildMessageContent(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isError = message.sender == MessageSender.error;

    return Text(
      _parseMarkdown(message.text),
      style: TextStyle(
        color: _getTextColor(context, isUser, isError),
        fontSize: 14,
      ),
    );
  }

  String _parseMarkdown(String text) {
    // Simple markdown parsing - in a real app you might want to use a proper markdown package
    return text
        .replaceAll('**', '') // Remove bold markers
        .replaceAll('*', '') // Remove italic markers
        .replaceAll('•', '• ') // Ensure bullet points have space
        .replaceAll('💰', '💰 ') // Ensure emojis have space
        .replaceAll('₹', '₹'); // Keep currency symbol
  }

  Widget _buildExpenseActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildActionButton(
            context,
            '📊 Download Excel',
            () => onExpenseAction?.call('download_excel', message.excelData),
            Colors.green,
          ),
          _buildActionButton(
            context,
            '📝 Download CSV',
            () => onExpenseAction?.call('download_csv', message.excelData),
            Colors.blue,
          ),
          _buildActionButton(
            context,
            '👁️ View Summary',
            () => onExpenseAction?.call('view_summary', message.excelData),
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    VoidCallback? onPressed,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
