import 'package:flutter/material.dart';

/// Paints a curved path on the specific edge of a container.
class CurvePainter extends CustomPainter {
  bool outerCurve;
  bool isPortrait;

  CurvePainter(this.outerCurve, this.isPortrait);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.blueAccent;
    paint.style = PaintingStyle.fill;

    Path path = Path();
    if (isPortrait) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.quadraticBezierTo(
        size.width * 0.5,
        outerCurve ? size.height + 100 : size.height - 100,
        size.width,
        size.height,
      );
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.quadraticBezierTo(
        outerCurve ? size.width + 80 : size.width - 80,
        size.height * 0.5,
        size.width,
        size.height,
      );
      path.lineTo(0, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
