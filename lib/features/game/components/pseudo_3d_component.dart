import 'package:flame/components.dart';

abstract class Pseudo3DComponent extends PositionComponent {
  double worldX;
  double worldY;
  double worldZ;

  static const double projectionScale = 500.0;

  static const double cameraZ = -10.0;

  Pseudo3DComponent({
    required this.worldX,
    required this.worldY,
    required this.worldZ,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _updateScreenPosition();
  }

  void _updateScreenPosition() {
    final effectiveZ = worldZ - cameraZ;

    if (effectiveZ <= 0) {
      scale = Vector2.zero();
      return;
    }

    final scaleFactor = projectionScale / effectiveZ;

    // Project world coordinates to screen coordinates
    // Assuming screen center is (0,0) for world coordinates, we'll offset by parent size later if needed
    x = worldX * scaleFactor;
    y = worldY * scaleFactor;

    scale = Vector2.all(scaleFactor);
    priority = (10000 - worldZ).toInt();
  }
}
