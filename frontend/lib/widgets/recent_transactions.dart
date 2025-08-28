import 'package:flutter/material.dart';
import '../models/transaction.dart';

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  // Sample data - in real app, this would come from a provider or service
  List<Transaction> get _sampleTransactions => [
    Transaction(
      id: '1',
      title: 'Starbucks Coffee',
      amount: 250.00,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: TransactionType.expense,
      category: 'Food',
      description: 'Morning coffee and croissant',
    ),
    Transaction(
      id: '2',
      title: 'Salary Credit',
      amount: 55000.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.income,
      category: 'Salary',
      description: 'Monthly salary',
    ),
    Transaction(
      id: '3',
      title: 'Uber Ride',
      amount: 180.00,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      type: TransactionType.expense,
      category: 'Transport',
      description: 'Ride to office',
    ),
    Transaction(
      id: '4',
      title: 'Netflix Subscription',
      amount: 649.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.expense,
      category: 'Entertainment',
      description: 'Monthly subscription',
    ),
    Transaction(
      id: '5',
      title: 'Freelance Payment',
      amount: 15000.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.income,
      category: 'Freelance',
      description: 'Web development project',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all transactions
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_sampleTransactions
                .take(4)
                .map(
                  (transaction) => _buildTransactionItem(context, transaction),
                )
                .toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = _getCategoryIcon(transaction.category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  transaction.category,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
              Text(
                _formatDate(transaction.date),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
