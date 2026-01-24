import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/runner_game.dart';

class BuildingComponent extends PositionComponent with HasGameRef<RunnerGame> {
  final double scrollSpeed = 2.0;
  double offset = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    offset += gameRef.currentSpeed * dt * scrollSpeed;
    if (offset > 200.0) {
      offset -= 200.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final size = gameRef.size;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw buildings on left and right sides
    for (int i = 0; i < 8; i++) {
      final y = (i * 200.0 - offset) % (size.y + 200);
      final height = 80.0 + (i % 3) * 40.0;

      final colorValue = 30 + (i % 5) * 15;
      final buildingColor =
          Color.fromARGB(255, colorValue, colorValue, colorValue + 20);

      // Left building
      paint.color = buildingColor;
      canvas.drawRect(
        Rect.fromLTWH(20, y - height, 60, height),
        paint,
      );

      // Windows
      paint.color = Colors.yellow.withOpacity(0.6);
      for (int w = 0; w < 3; w++) {
        for (int h = 0; h < 4; h++) {
          canvas.drawRect(
            Rect.fromLTWH(30 + w * 15, y - height + 10 + h * 20, 8, 12),
            paint,
          );
        }
      }

      // Right building
      paint.color = buildingColor;
      canvas.drawRect(
        Rect.fromLTWH(size.x - 80, y - height, 60, height),
        paint,
      );

      // Windows
      paint.color = Colors.yellow.withOpacity(0.6);
      for (int w = 0; w < 3; w++) {
        for (int h = 0; h < 4; h++) {
          canvas.drawRect(
            Rect.fromLTWH(
                size.x - 70 + w * 15, y - height + 10 + h * 20, 8, 12),
            paint,
          );
        }
      }
    }
  }
}
