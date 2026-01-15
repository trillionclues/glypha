import 'dart:ui';
import 'package:flame/components.dart';

abstract class Pseudo3DComponent extends PositionComponent {
  double worldX;
  double worldY;
  double worldZ;

  // The "focal length" or scale factor for the projection
  static const double projectionScale = 500.0;

  // The Z coordinate of the camera (viewer)
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
    // Avoid division by zero or negative Z behind camera
    final effectiveZ = worldZ - cameraZ;

    if (effectiveZ <= 0) {
      // Object is behind camera, hide it or handle accordingly
      scale = Vector2.zero();
      return;
    }

    final scaleFactor = projectionScale / effectiveZ;

    // Project world coordinates to screen coordinates
    // Assuming screen center is (0,0) for world coordinates, we'll offset by parent size later if needed
    // But typically in Flame, we can center the camera or the world container.
    // Here we calculate relative to the center of the screen/container.

    x = worldX * scaleFactor;
    y = worldY * scaleFactor;

    // Scale the object visual size based on depth
    scale = Vector2.all(scaleFactor);

    // Update priority (z-index) so closer objects are drawn on top
    // Higher priority = drawn later (on top).
    // Closer objects (smaller Z) should have higher priority.
    priority = (10000 - worldZ).toInt();
  }
}
