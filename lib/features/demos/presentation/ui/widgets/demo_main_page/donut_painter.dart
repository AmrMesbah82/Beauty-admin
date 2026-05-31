// ******************* FILE INFO *******************
// File Name: donut_painter.dart
// Description: Donut chart custom painter for Demo
// Created by: Amr Mesbah
// Last Update: 31/05/2026

/// Module: features › demos › presentation › ui › widget › demo_main_page

part of '../../pages/demo_main_page.dart';

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  final String centerLabel;
  final String centerValue;

  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.centerLabel,
    required this.centerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.54;
    final rect   = Rect.fromCircle(center: centre, radius: outerR);

    double startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, true,
          Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill);
      canvas.drawArc(rect, startAngle, sweep, true,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      startAngle += sweep;
    }

    canvas.drawCircle(centre, innerR, Paint()..color = Colors.white);

    final labelSp = TextSpan(
      text: centerLabel,
      style: TextStyle(fontSize: size.width * 0.11, color: const Color(0xFFAAAAAA), fontWeight: FontWeight.w500),
    );
    final valueSp = TextSpan(
      text: centerValue,
      style: TextStyle(fontSize: size.width * 0.20, color: const Color(0xFF333333), fontWeight: FontWeight.w700),
    );

    final labelTp = TextPainter(text: labelSp, textDirection: TextDirection.ltr)..layout();
    final valueTp = TextPainter(text: valueSp, textDirection: TextDirection.ltr)..layout();

    const gap = 1.0;
    final totalTextH = labelTp.height + gap + valueTp.height;
    final topY       = centre.dy - totalTextH / 2;

    labelTp.paint(canvas, Offset(centre.dx - labelTp.width / 2, topY));
    valueTp.paint(canvas, Offset(centre.dx - valueTp.width / 2, topY + labelTp.height + gap));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.values != values || old.colors != colors || old.centerValue != centerValue;
}
