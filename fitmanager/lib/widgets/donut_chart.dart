import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Gráfica de dona simple (sin dependencias externas) equivalente a la
/// gráfica Chart.js tipo "doughnut" que se usa en la web para Asistencia y
/// Metas: muestra un porcentaje de avance vs. lo faltante.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.percent,
    required this.progressColor,
    required this.remainingColor,
    this.size = 150,
    this.strokeWidth = 18,
    this.centerText,
    this.centerSubText,
  });

  /// Valor entre 0 y 100.
  final double percent;
  final Color progressColor;
  final Color remainingColor;
  final double size;
  final double strokeWidth;
  final String? centerText;
  final String? centerSubText;

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: p),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              percent: value,
              progressColor: progressColor,
              remainingColor: remainingColor,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        if (centerText != null)
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerText!,
                style: TextStyle(
                    color: kText,
                    fontSize: size * 0.16,
                    fontWeight: FontWeight.w800)),
            if (centerSubText != null)
              Text(centerSubText!,
                  style: TextStyle(color: kTextSub, fontSize: size * 0.08)),
          ]),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.percent,
    required this.progressColor,
    required this.remainingColor,
    required this.strokeWidth,
  });

  final double percent;
  final Color progressColor;
  final Color remainingColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..color = remainingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, basePaint);

    final sweep = 2 * math.pi * (percent / 100);
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.remainingColor != remainingColor;
}

