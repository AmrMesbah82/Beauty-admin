// ******************* FILE INFO *******************
// File Name: pie_painter.dart
// Description: Pie chart custom painter for Inquiry
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › inquire › presentation › ui › widget › inquiry_main

part of '../../pages/inquiry_main.dart';

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  const _PiePainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final rect   = Rect.fromLTWH(0, 0, size.width, size.height);
    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill);
      canvas.drawArc(rect, start, sweep, true, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.values != values;
}

// ─────────────────────────────────────────────────────────────────────────────
//  DONUT PAINTER
// ─────────────────────────────────────────────────────────────────────────────
