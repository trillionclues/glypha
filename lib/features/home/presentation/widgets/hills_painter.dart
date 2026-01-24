import 'package:flutter/material.dart';

class HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Back hills (darkest green - furthest away)
    final backHillPaint = Paint()
      ..color = const Color(0xFF5A8F6A)
      ..style = PaintingStyle.fill;

    final backHillPath = Path();
    backHillPath.moveTo(0, size.height * 0.45);
    backHillPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.4,
      size.height * 0.38,
    );
    backHillPath.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.46,
      size.width * 0.8,
      size.height * 0.35,
    );
    backHillPath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.32,
    );
    backHillPath.lineTo(size.width, size.height);
    backHillPath.lineTo(0, size.height);
    backHillPath.close();

    canvas.drawPath(backHillPath, backHillPaint);

    // Middle hills (medium green)
    final midHillPaint = Paint()
      ..color = const Color(0xFF6FA580)
      ..style = PaintingStyle.fill;

    final midHillPath = Path();
    midHillPath.moveTo(0, size.height * 0.52);
    midHillPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.48,
    );
    midHillPath.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.54,
      size.width * 0.85,
      size.height * 0.45,
    );
    midHillPath.quadraticBezierTo(
      size.width * 0.92,
      size.height * 0.42,
      size.width,
      size.height * 0.44,
    );
    midHillPath.lineTo(size.width, size.height);
    midHillPath.lineTo(0, size.height);
    midHillPath.close();

    canvas.drawPath(midHillPath, midHillPaint);

    // Front grass layer (lighter green - closest)
    final frontGrassPaint = Paint()
      ..color = const Color(0xFF84BB96)
      ..style = PaintingStyle.fill;

    final frontGrassPath = Path();
    frontGrassPath.moveTo(0, size.height * 0.58);
    frontGrassPath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.52,
      size.width * 0.55,
      size.height * 0.56,
    );
    frontGrassPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.59,
      size.width * 0.88,
      size.height * 0.54,
    );
    frontGrassPath.quadraticBezierTo(
      size.width * 0.94,
      size.height * 0.52,
      size.width,
      size.height * 0.53,
    );
    frontGrassPath.lineTo(size.width, size.height);
    frontGrassPath.lineTo(0, size.height);
    frontGrassPath.close();

    canvas.drawPath(frontGrassPath, frontGrassPaint);

    // Very front grass patches (lightest - for depth)
    final veryFrontPaint = Paint()
      ..color = const Color(0xFF9CD3AD)
      ..style = PaintingStyle.fill;

    final veryFrontPath = Path();
    veryFrontPath.moveTo(0, size.height * 0.65);
    veryFrontPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.6,
      size.width * 0.6,
      size.height * 0.63,
    );
    veryFrontPath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.66,
      size.width,
      size.height * 0.62,
    );
    veryFrontPath.lineTo(size.width, size.height);
    veryFrontPath.lineTo(0, size.height);
    veryFrontPath.close();

    canvas.drawPath(veryFrontPath, veryFrontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
