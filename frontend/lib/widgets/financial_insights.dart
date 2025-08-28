import 'package:flutter/material.dart';
import '../models/transaction.dart';

class FinancialInsightsWidget extends StatelessWidget {
  const FinancialInsightsWidget({super.key});

  List<FinancialInsight> get _insights => [
    FinancialInsight(
      title: 'Great Savings!',
      description:
          'You\'ve saved 15% more this month compared to last month. Keep it up!',
      value: 15,
      type: InsightType.savings,
      generatedAt: DateTime.now(),
    ),
    FinancialInsight(
      title: 'Food Budget Alert',
      description:
          'You\'re spending 23% more on food this week. Consider meal planning.',
      value: 23,
      type: InsightType.warning,
      generatedAt: DateTime.now(),
    ),
    FinancialInsight(
      title: 'Investment Opportunity',
      description: 'You have ₹12,000 sitting idle. Consider investing in SIP.',
      value: 12000,
      type: InsightType.investment,
      generatedAt: DateTime.now(),
    ),
    FinancialInsight(
      title: 'Budget Goal Achieved!',
      description: 'Congratulations! You\'ve stayed under your monthly budget.',
      value: 100,
      type: InsightType.achievement,
      generatedAt: DateTime.now(),
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
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Financial Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AI Generated',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_insights.map(
              (insight) => _buildInsightItem(context, insight),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, FinancialInsight insight) {
    final config = _getInsightConfig(insight.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(config.icon, color: config.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: config.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (insight.type == InsightType.warning)
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey.shade600,
            ),
        ],
      ),
    );
  }

  _InsightConfig _getInsightConfig(InsightType type) {
    switch (type) {
      case InsightType.savings:
        return _InsightConfig(Colors.green, Icons.savings);
      case InsightType.expense:
        return _InsightConfig(Colors.orange, Icons.trending_down);
      case InsightType.budget:
        return _InsightConfig(Colors.blue, Icons.account_balance_wallet);
      case InsightType.investment:
        return _InsightConfig(Colors.purple, Icons.trending_up);
      case InsightType.warning:
        return _InsightConfig(Colors.amber, Icons.warning);
      case InsightType.achievement:
        return _InsightConfig(Colors.teal, Icons.emoji_events);
    }
  }
}

class _InsightConfig {
  final Color color;
  final IconData icon;

  _InsightConfig(this.color, this.icon);
}
