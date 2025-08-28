import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'expense_form.dart';
import '../screens/investment_portfolio_screen.dart';
import '../screens/analytics_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                Expanded(
                  child: _ActionTile(
                    icon: actions[i].icon,
                    label: actions[i].label,
                    color: actions[i].color,
                    onTap: actions[i].onTap,
                  ),
                ),
                if (i != actions.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<_QuickAction> _buildActions(BuildContext context) => [
    _QuickAction(
      icon: Icons.add_circle_outline,
      label: 'Expense',
      color: Colors.red,
      onTap: () => _openExpenseForm(context, TransactionType.expense),
    ),
    _QuickAction(
      icon: Icons.attach_money,
      label: 'Income',
      color: Colors.green,
      onTap: () => _openExpenseForm(context, TransactionType.income),
    ),
    _QuickAction(
      icon: Icons.trending_up,
      label: 'Investment',
      color: Colors.blue,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const InvestmentPortfolioScreen()),
      ),
    ),
    _QuickAction(
      icon: Icons.analytics,
      label: 'Analytics',
      color: Colors.purple,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
    ),
  ];

  void _openExpenseForm(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ExpenseFormWidget(
              initialType: type,
              onSave: (tx) {
                // TODO: propagate to global state if needed
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${tx.type == TransactionType.expense ? 'Expense' : 'Income'} added successfully',
                    ),
                    backgroundColor: tx.type == TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(.07),
          border: Border.all(color: color.withOpacity(.22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(.85),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
