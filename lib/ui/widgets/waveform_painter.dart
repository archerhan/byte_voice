import 'package:flutter/material.dart';

/// 实时声波图绘制器 — 根据振幅列表绘制垂直条形波形
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  WaveformPainter({required this.amplitudes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final n = amplitudes.length;
    if (n == 0) {
      // 无数据时画一条细微的基线
      final midY = size.height / 2;
      paint.strokeWidth = 1.0;
      paint.color = color.withValues(alpha: 0.15);
      canvas.drawLine(Offset(0, midY), Offset(size.width, midY), paint);
      return;
    }

    final barWidth = size.width / n;
    final centerY = size.height / 2;
    final maxBarHeight = size.height * 0.38; // 留边距，不顶天立地

    for (int i = 0; i < n; i++) {
      final x = barWidth * i + barWidth / 2;
      final amplitude = amplitudes[i].clamp(0.0, 1.0);
      final barHeight = amplitude * maxBarHeight;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}
