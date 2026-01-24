import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/runner_game.dart';

class HorizonComponent extends PositionComponent with HasGameRef<RunnerGame> {
  static const double horizonY = 0.4;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final size = gameRef.size;
    final horizonHeight = size.y * horizonY;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, horizonHeight),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000033), Color(0xFF442266)],
        ).createShader(Rect.fromLTWH(0, 0, size.x, horizonHeight)),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, horizonHeight, size.x, size.y - horizonHeight),
      Paint()..color = const Color(0xFF222222),
    );

    _drawGrid(canvas, size, horizonHeight);
  }

  double _offset = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset += gameRef.currentSpeed * dt * 5.0;
    if (_offset > 100.0) {
      _offset -= 100.0;
    }
  }

  void _drawGrid(Canvas canvas, Vector2 size, double horizonHeight) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = size.x / 2;
    final bottomY = size.y;

    for (int i = -2; i <= 2; i++) {
      final spread = size.x * 0.8;
      final xBottom = centerX + (i * spread / 2);

      canvas.drawLine(
        Offset(centerX, horizonHeight),
        Offset(xBottom, bottomY),
        paint,
      );
    }

    for (double i = 0; i < 20; i++) {
      // 0 is near, 1 is far (horizon)
      // We want lines to move from horizon to bottom

      // Calculate "z" depth
      // Let's say we have lines at z = 10, 20, 30...
      final zBase = (i * 50.0) - _offset;
      final z = zBase % 1000.0;

      if (z < 1.0) continue;

      final t = 200.0 / (z + 50.0);

      if (t > 1.0 || t < 0.0) continue;

      final y = horizonHeight + (bottomY - horizonHeight) * t;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        paint,
      );
    }
  }
}
