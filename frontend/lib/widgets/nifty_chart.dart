import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class NiftyChart extends StatelessWidget {
  final List<NiftyDataPoint> data;

  const NiftyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final values = data.map((d) => d.value.toDouble()).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final lastValue = values.last;
    final firstValue = values.first;
    final isPositive = lastValue >= firstValue;

    return Container(
      height: 120,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lastValue.toInt()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _ChartPainter(
                data: data,
                minValue: minValue,
                maxValue: maxValue,
                isPositive: isPositive,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data
                .asMap()
                .entries
                .where((entry) => entry.key % 4 == 0)
                .map(
                  (entry) => Text(
                    entry.value.time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<NiftyDataPoint> data;
  final double minValue;
  final double maxValue;
  final bool isPositive;

  _ChartPainter({
    required this.data,
    required this.minValue,
    required this.maxValue,
    required this.isPositive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = isPositive ? Colors.green : Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0
          ? (data[i].value - minValue) / range
          : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
