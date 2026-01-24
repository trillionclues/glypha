import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CharacterSprite extends PositionComponent {
  double animationTime = 0.0;

  double _hoverOffset = 0.0;

  CharacterSprite() : super(size: Vector2(1.0, 1.5));

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt * 5.0;
    _hoverOffset = math.sin(animationTime) * 0.05;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(0.1, 1.3, 0.8, 0.2),
      Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.save();
    canvas.translate(0, _hoverOffset);

    // === HOVERBOARD ===
    // Main deck
    final boardPath = Path()
      ..moveTo(0.2, 1.2)
      ..lineTo(0.8, 1.2)
      ..lineTo(0.9, 0.8)
      ..lineTo(0.5, 0.7)
      ..lineTo(0.1, 0.8)
      ..close();

    paint.color = const Color(0xFF2D3748);
    canvas.drawPath(boardPath, paint);

    final rimPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    canvas.drawPath(boardPath, rimPaint);

    final thrustPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(const Offset(0.3, 1.2), 0.08, thrustPaint);
    canvas.drawCircle(const Offset(0.7, 1.2), 0.08, thrustPaint);

    // === RIDER (Cyber Silhouette) ===
    paint.color = const Color(0xFF1A202C); // Dark suit
    final leftLeg = Path()
      ..moveTo(0.35, 1.0)
      ..lineTo(0.3, 0.8) // Knee
      ..lineTo(0.45, 0.6) // Hip
      ..lineTo(0.5, 1.0)
      ..close();
    canvas.drawPath(leftLeg, paint);

    final rightLeg = Path()
      ..moveTo(0.65, 1.0)
      ..lineTo(0.7, 0.8) // Knee
      ..lineTo(0.55, 0.6) // Hip
      ..lineTo(0.5, 1.0)
      ..close();
    canvas.drawPath(rightLeg, paint);

    final torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.4, 0.35, 0.2, 0.35),
      const Radius.circular(0.05),
    );
    paint.color = const Color(0xFF2D3748);
    canvas.drawRRect(torso, paint);

    paint.color = const Color(0xFFFF0080); // Neon Pink stripe
    canvas.drawRect(Rect.fromLTWH(0.48, 0.38, 0.04, 0.3), paint);

    paint.color = const Color(0xFFCBD5E0); // Silver/White Helmet
    final headRect = Rect.fromLTWH(0.4, 0.15, 0.2, 0.22);
    canvas.drawOval(headRect, paint);

    paint.color = const Color(0xFF00E5FF);
    canvas.drawRect(Rect.fromLTWH(0.42, 0.22, 0.16, 0.06), paint);

    paint.color = const Color(0xFF1A202C);
    canvas.drawRect(Rect.fromLTWH(0.25, 0.4, 0.15, 0.08), paint);
    canvas.drawRect(Rect.fromLTWH(0.6, 0.4, 0.15, 0.08), paint);

    canvas.restore();
  }
}
