part of '../../pages/inquiry_main.dart';

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  const _DonutPainter({required this.values, required this.colors});

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
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 * 0.55,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.values != values;
}
