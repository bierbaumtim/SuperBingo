import 'package:flutter/material.dart';

/// Erstellt das Karo-Muster auf der Rückseiter jeder Spielkarte
class CardBackPainter extends CustomPainter {
  const CardBackPainter({Listenable repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    const lineHeight = 20.0;
    final paint = Paint();
    final customSize = Size.square(size.height * 1.2);

    paint.color = Colors.deepOrange;

    // top line
    var rect = Rect.fromLTWH(0, 0, customSize.width, 10);

    canvas.drawRect(rect, paint);

    // left line
    rect = Rect.fromLTWH(0, 0, 10, customSize.height);

    canvas.drawRect(rect, paint);

    // right line
    rect = Rect.fromLTWH(customSize.width - 10, 0, 10, customSize.height);

    canvas.drawRect(rect, paint);

    // bottom line
    rect = Rect.fromLTWH(0, customSize.height - 10, customSize.width, 10);

    canvas.drawRect(rect, paint);

    final horizontalLines = customSize.height ~/ lineHeight;

    // horizontale Linien
    for (var i = 0; i < horizontalLines; i++) {
      if (i & 1 != 0) continue;

      final topPoint = (i * lineHeight) + lineHeight;
      final bottomPoint = topPoint + lineHeight;
      paint.color = Colors.deepOrangeAccent;

      final rect = Rect.fromPoints(
        Offset(0, topPoint),
        Offset(customSize.width, bottomPoint),
      );

      canvas.drawRect(rect, paint);
    }

    final verticalLines = (customSize.width - 20) ~/ lineHeight;

    // vetikale Linien
    for (var i = 0; i < verticalLines; i++) {
      if (i & 1 != 0) continue;
      final leftPoint = ((i + 1) * lineHeight) + lineHeight;
      final rightPoint = leftPoint + lineHeight;
      paint.color = Colors.deepOrange;

      final rect = Rect.fromPoints(
        Offset(leftPoint, 0),
        Offset(rightPoint, customSize.height),
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
