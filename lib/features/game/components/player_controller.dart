import 'package:flame/components.dart';
import 'pseudo_3d_component.dart';
import 'character_sprite.dart';

class PlayerController extends Pseudo3DComponent {
  int currentLane = 0; // -1, 0, 1
  static const double laneWidth = 2.5; // Match gate spacing
  static const double moveSpeed = 10.0;

  double targetX = 0;

  PlayerController()
      : super(worldX: 0, worldY: 2.5, worldZ: -5.0); // Y: 2.5 for bottom

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Add smaller car sprite
    add(CharacterSprite()
          ..position =
              Vector2(-0.4, -1.2) // Centered and adjusted for smaller size
        );
  }

  @override
  void update(double dt) {
    // Smoothly interpolate worldX to targetX
    if ((worldX - targetX).abs() > 0.01) {
      final direction = (targetX - worldX).sign;
      worldX += direction * moveSpeed * dt;

      // Snap if we overshoot
      if ((targetX - worldX).sign != direction) {
        worldX = targetX;
      }
    } else {
      worldX = targetX;
    }

    // Clamp worldX to prevent going off-screen
    // Lanes are at -2.5, 0, 2.5, so clamp between -2.5 and 2.5
    worldX = worldX.clamp(-2.5, 2.5);

    super.update(dt);
  }

  void moveLeft() {
    if (currentLane > -1) {
      currentLane--;
      currentLane = currentLane.clamp(-1, 1); // Ensure bounds
      targetX = currentLane * laneWidth;
    }
  }

  void moveRight() {
    if (currentLane < 1) {
      currentLane++;
      currentLane = currentLane.clamp(-1, 1); // Ensure bounds
      targetX = currentLane * laneWidth;
    }
  }
}
