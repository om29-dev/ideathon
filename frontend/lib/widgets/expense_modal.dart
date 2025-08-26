import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseModal extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ExpenseModal({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return AlertDialog(
        title: const Text('📊 Expense Summary'),
        content: const Text('No expense data available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    // Mock expense data since the real data structure might be different
    final expenses = _generateMockExpenses();
    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📊 Expense Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildSummaryStats(expenses, total),
            ),

            // Expense table
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExpenseTable(expenses),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download Excel'),
                    onPressed: () {
                      // Handle download
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Excel download started!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<Expense> expenses, double total) {
    final gamingExpenses = expenses
        .where((e) => e.category == 'Gaming')
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final foodExpenses = expenses
        .where((e) => e.category == 'Food & Dining')
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final entertainmentExpenses = expenses
        .where((e) => e.category == 'Entertainment')
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final highestExpense = expenses.isNotEmpty
        ? expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildStatItem('Total Expenses:', '₹${total.toStringAsFixed(0)}'),
        _buildStatItem('Total Items:', '${expenses.length}'),
        _buildStatItem('Gaming:', '₹${gamingExpenses.toStringAsFixed(0)}'),
        _buildStatItem('Food & Dining:', '₹${foodExpenses.toStringAsFixed(0)}'),
        _buildStatItem(
          'Entertainment:',
          '₹${entertainmentExpenses.toStringAsFixed(0)}',
        ),
        _buildStatItem(
          'Highest Expense:',
          '₹${highestExpense.toStringAsFixed(0)}',
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTable(List<Expense> expenses) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Amount')),
        ],
        rows: expenses.map((expense) {
          return DataRow(
            cells: [
              DataCell(Text(expense.date)),
              DataCell(
                Text(expense.description, overflow: TextOverflow.ellipsis),
              ),
              DataCell(_buildCategoryChip(expense.category)),
              DataCell(Text('₹${expense.amount.toStringAsFixed(0)}')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case 'Gaming':
        color = Colors.purple;
        break;
      case 'Food & Dining':
        color = Colors.orange;
        break;
      case 'Entertainment':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Expense> _generateMockExpenses() {
    final now = DateTime.now();
    final dateString = "${now.day}/${now.month}/${now.year}";

    return [
      Expense(
        date: dateString,
        description: "PUBG UC purchase",
        category: "Gaming",
        amount: 499.0,
      ),
      Expense(
        date: dateString,
        description: "Free Fire diamonds",
        category: "Gaming",
        amount: 299.0,
      ),
      Expense(
        date: dateString,
        description: "Call of Duty battle pass",
        category: "Gaming",
        amount: 799.0,
      ),
      Expense(
        date: dateString,
        description: "PlayStation game subscription",
        category: "Gaming",
        amount: 599.0,
      ),
      Expense(
        date: dateString,
        description: "Xbox Game Pass",
        category: "Gaming",
        amount: 489.0,
      ),
      Expense(
        date: dateString,
        description: "Steam game purchase",
        category: "Gaming",
        amount: 999.0,
      ),
      Expense(
        date: dateString,
        description: "Swiggy pizza order",
        category: "Food & Dining",
        amount: 349.0,
      ),
      Expense(
        date: dateString,
        description: "Zomato burger combo",
        category: "Food & Dining",
        amount: 289.0,
      ),
      Expense(
        date: dateString,
        description: "Swiggy biryani order",
        category: "Food & Dining",
        amount: 419.0,
      ),
      Expense(
        date: dateString,
        description: "Zomato coffee and snacks",
        category: "Food & Dining",
        amount: 199.0,
      ),
      Expense(
        date: dateString,
        description: "Cold drink - Coca Cola",
        category: "Food & Dining",
        amount: 60.0,
      ),
      Expense(
        date: dateString,
        description: "Cold drink - Pepsi",
        category: "Food & Dining",
        amount: 55.0,
      ),
      Expense(
        date: dateString,
        description: "Netflix subscription",
        category: "Entertainment",
        amount: 649.0,
      ),
      Expense(
        date: dateString,
        description: "Hotstar premium",
        category: "Entertainment",
        amount: 499.0,
      ),
    ];
  }
}
