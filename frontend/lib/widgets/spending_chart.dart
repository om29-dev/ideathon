import 'package:flutter/material.dart';

class SpendingChartWidget extends StatelessWidget {
  const SpendingChartWidget({super.key});

  final List<SpendingData> _spendingData = const [
    SpendingData('Food', 5500, Colors.orange),
    SpendingData('Transport', 2800, Colors.blue),
    SpendingData('Entertainment', 1200, Colors.purple),
    SpendingData('Shopping', 3400, Colors.pink),
    SpendingData('Bills', 4200, Colors.red),
    SpendingData('Others', 800, Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _spendingData.fold<double>(
      0,
      (sum, data) => sum + data.amount,
    );

    return Column(
      children: [
        // Pie Chart representation (simplified as progress bars)
        Container(
          height: 150,
          child: Row(
            children: _spendingData.map((data) {
              final percentage = (data.amount / total);
              return Expanded(
                flex: (percentage * 100).round(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: percentage > 0.15
                      ? Center(
                          child: Text(
                            '${(percentage * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: _spendingData.map((data) {
            final percentage = ((data.amount / total) * 100).toInt();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${data.category} ($percentage%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Spending breakdown
        ...(_spendingData.map(
          (data) => _buildSpendingRow(context, data, total),
        )),
      ],
    );
  }

  Widget _buildSpendingRow(
    BuildContext context,
    SpendingData data,
    double total,
  ) {
    final percentage = (data.amount / total);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${data.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(data.color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

class SpendingData {
  final String category;
  final double amount;
  final Color color;

  const SpendingData(this.category, this.amount, this.color);
}
