import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Simple sparkline-like Nifty 50 mock chart (no API yet)
class NiftyIndexChart extends StatelessWidget {
  final List<double> data;
  final double latestValue;
  final double changePercent;
  final bool isPositive;

  const NiftyIndexChart({
    super.key,
    required this.data,
    required this.latestValue,
    required this.changePercent,
    required this.isPositive,
  });

  factory NiftyIndexChart.mock() {
    final rand = math.Random();
    final base = 24500.0;
    final points = List<double>.generate(32, (i) {
      final drift = (i / 40.0) * 120; // upward drift
      final noise = rand.nextDouble() * 150 - 75; // +/- noise
      return base + drift + noise;
    });
    final latest = points.last;
    final first = points.first;
    final changePct = ((latest - first) / first) * 100;
    return NiftyIndexChart(
      data: points,
      latestValue: latest,
      changePercent: changePct,
      isPositive: changePct >= 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? Colors.green : Colors.red;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Nifty 50',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${isPositive ? '▲' : '▼'} ${changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              latestValue.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: CustomPaint(
                painter: _SparklinePainter(data: data, color: color),
                size: const Size(double.infinity, 80),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mock data for demonstration',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).clamp(1, double.infinity);
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      final normY = (data[i] - minV) / range;
      final y = size.height - (normY * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(.25), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
