import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/runner_game.dart';

class HorizonComponent extends PositionComponent with HasGameRef<RunnerGame> {
  // Horizon line Y position (0.0 to 1.0 relative to screen height)
  static const double horizonY = 0.4;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final size = gameRef.size;
    final horizonHeight = size.y * horizonY;

    // Draw Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, horizonHeight),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000033), Color(0xFF442266)],
        ).createShader(Rect.fromLTWH(0, 0, size.x, horizonHeight)),
    );

    // Draw Floor (Road)
    canvas.drawRect(
      Rect.fromLTWH(0, horizonHeight, size.x, size.y - horizonHeight),
      Paint()..color = const Color(0xFF222222),
    );

    // Draw moving grid lines on floor to simulate speed
    _drawGrid(canvas, size, horizonHeight);
  }

  double _offset = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    // Move grid lines based on speed
    _offset += gameRef.currentSpeed * dt * 5.0; // Multiplier for visual speed
    if (_offset > 100.0) {
      _offset -= 100.0;
    }
  }

  void _drawGrid(Canvas canvas, Vector2 size, double horizonHeight) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Perspective lines (lanes)
    // Center is size.x / 2
    final centerX = size.x / 2;
    final bottomY = size.y;

    // Draw 4 lines for 3 lanes
    // Vanishing point is at (centerX, horizonHeight)
    // Bottom points spread out

    for (int i = -2; i <= 2; i++) {
      // Calculate x at bottom
      // Spread factor
      final spread = size.x * 0.8;
      final xBottom = centerX + (i * spread / 2);

      canvas.drawLine(
        Offset(centerX, horizonHeight),
        Offset(xBottom, bottomY),
        paint,
      );
    }

    // Horizontal moving lines
    // They should get closer together near horizon
    // Simple exponential or 1/z distribution

    for (double i = 0; i < 20; i++) {
      // 0 is near, 1 is far (horizon)
      // We want lines to move from horizon to bottom

      // Calculate "z" depth
      // Let's say we have lines at z = 10, 20, 30...
      // Project them to Y

      final zBase = (i * 50.0) - _offset;
      // Wrap z
      final z = zBase % 1000.0;

      if (z < 1.0) continue;

      // Project Z to Y (0 to 1)
      // Simple perspective: y = 1 / z
      // But we want y to map to screen Y

      // Let's use a simpler linear interpolation for visual effect
      // t goes from 0 (horizon) to 1 (bottom)
      // t = 1 / (z * constant)

      final t = 200.0 / (z + 50.0); // +50 to avoid div by 0 and push start away

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
