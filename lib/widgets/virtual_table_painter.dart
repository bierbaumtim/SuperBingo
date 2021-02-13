import 'package:flutter/material.dart';

import 'package:superbingo/constants/ui_constants.dart';

class VirtualTablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = Colors.blueAccent;
    final innerBorderPaint = Paint()..color = Colors.black.withOpacity(0.1);
    final outerBorderPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    Path basePath, borderPath, upperPath;

    if (size.width >= size.height) {
      basePath = _buildHorizontalTableBaseShape(size);
      borderPath = _buildHorizontalTableBaseShape(
        size * 0.975,
      ).shift(
        Offset(size.width * 0.0125, size.height * 0.0125),
      );
      upperPath = _buildHorizontalTableBaseShape(
        size * 0.95,
      ).shift(
        Offset(size.width * 0.025, size.height * 0.025),
      );
    } else {
      basePath = _buildVerticalTableBaseShape(size);
      borderPath = _buildVerticalTableBaseShape(
        size * 0.975,
      ).shift(
        Offset(size.width * 0.0125, size.height * 0.0125),
      );
      upperPath = _buildVerticalTableBaseShape(
        size * 0.95,
      ).shift(
        Offset(size.width * 0.025, size.height * 0.025),
      );
    }
    canvas.drawShadow(basePath, Colors.black87, 4, false);
    canvas.drawPath(basePath, basePaint);
    canvas.drawPath(borderPath, innerBorderPaint);
    canvas.drawPath(upperPath, basePaint);
    canvas.drawPath(basePath, outerBorderPaint);
  }

  Path _buildVerticalTableBaseShape(Size size) {
    final innerHeight = size.height * kTableInnerSizeFactor;
    final endsRadius = (size.height - innerHeight) / 2;

    return Path()
      ..moveTo(size.width, endsRadius)
      ..relativeLineTo(0, innerHeight)
      ..relativeArcToPoint(
        Offset(-size.width, 0),
        radius: Radius.elliptical(size.width / 2, endsRadius),
      )
      ..relativeLineTo(0, -innerHeight)
      ..relativeArcToPoint(
        Offset(size.width, 0),
        radius: Radius.elliptical(size.width / 2, endsRadius),
      )
      ..close();
  }

  Path _buildHorizontalTableBaseShape(Size size) {
    final innerWidth = size.width * kTableInnerSizeFactor;
    final endsRadius = (size.width - innerWidth) / 2;

    // debugPrint('========= Painter =========');
    // debugPrint('Size: $size');
    // debugPrint('InnerWidth: $innerWidth');
    // debugPrint('CalcWidth: ${innerWidth + 2 * endsRadius}');
    // debugPrint('========= Painter =========');

    return Path()
      ..moveTo(endsRadius, 0)
      ..relativeLineTo(innerWidth, 0)
      ..relativeArcToPoint(
        Offset(0, size.height),
        radius: Radius.circular(endsRadius),
      )
      ..relativeLineTo(-innerWidth, 0)
      ..relativeArcToPoint(
        Offset(0, -size.height),
        radius: Radius.circular(endsRadius),
      )
      ..close();
  }

  @override
  bool shouldRepaint(VirtualTablePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(VirtualTablePainter oldDelegate) => false;
}
