import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A simple 2D robot character sprite
class CharacterSprite extends PositionComponent {
  double animationTime = 0.0;

  CharacterSprite() : super(size: Vector2(0.8, 1.2));

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..style = PaintingStyle.fill;

    // Robot body (main rectangle)
    paint.color = const Color(0xFF4A90E2);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.15, 0.4, 0.5, 0.6),
      const Radius.circular(0.05),
    );
    canvas.drawRRect(bodyRect, paint);

    // Robot head
    paint.color = const Color(0xFF5BA3F5);
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.2, 0.15, 0.4, 0.35),
      const Radius.circular(0.08),
    );
    canvas.drawRRect(headRect, paint);

    // Eyes (animated blink)
    final eyeOpen = (animationTime % 3.0) > 2.8 ? 0.03 : 0.08;
    paint.color = Colors.white;
    canvas.drawCircle(Offset(0.3, 0.3), eyeOpen, paint);
    canvas.drawCircle(Offset(0.5, 0.3), eyeOpen, paint);

    // Eye pupils
    if (eyeOpen > 0.05) {
      paint.color = Colors.black87;
      canvas.drawCircle(const Offset(0.3, 0.3), 0.04, paint);
      canvas.drawCircle(const Offset(0.5, 0.3), 0.04, paint);
    }

    // Antenna
    paint.color = const Color(0xFF357ABD);
    canvas.drawRect(
      Rect.fromLTWH(0.38, 0.05, 0.04, 0.15),
      paint,
    );

    // Antenna ball
    paint.color = Colors.red;
    canvas.drawCircle(const Offset(0.4, 0.05), 0.05, paint);

    // Arms (animated wave)
    final armWave = (animationTime % 2.0) * 0.1;
    paint.color = const Color(0xFF4A90E2);

    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.05, 0.5 + armWave, 0.12, 0.4),
        const Radius.circular(0.03),
      ),
      paint,
    );

    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.63, 0.5 - armWave, 0.12, 0.4),
        const Radius.circular(0.03),
      ),
      paint,
    );

    // Legs
    paint.color = const Color(0xFF357ABD);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.2, 1.0, 0.15, 0.15),
        const Radius.circular(0.03),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.45, 1.0, 0.15, 0.15),
        const Radius.circular(0.03),
      ),
      paint,
    );

    // Chest panel
    paint.color = const Color(0xFF87CEEB);
    canvas.drawRect(
      Rect.fromLTWH(0.3, 0.6, 0.2, 0.25),
      paint,
    );

    // Chest buttons
    paint.color = Colors.green;
    canvas.drawCircle(const Offset(0.35, 0.7), 0.03, paint);
    paint.color = Colors.red;
    canvas.drawCircle(const Offset(0.45, 0.7), 0.03, paint);
  }
}
