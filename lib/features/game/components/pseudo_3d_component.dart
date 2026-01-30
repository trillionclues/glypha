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

    // Calculate scale with a cap to prevent oversized textures
    // Max scale of ~15-20 keeps textures safely under 8192 limit
    // final rawScaleFactor = projectionScale / effectiveZ;
    // final scaleFactor = rawScaleFactor.clamp(0.01, 18.0);
    final scaleFactor = projectionScale / effectiveZ;

    // Project world coordinates to screen coordinates
    x = worldX * scaleFactor;
    y = worldY * scaleFactor;

    scale = Vector2.all(scaleFactor);
    priority = (10000 - worldZ).toInt();
  }
}
