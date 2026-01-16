import 'package:flame/components.dart';
import 'pseudo_3d_component.dart';
import 'character_sprite.dart';

enum PlayerReaction { normal, boosted, stumbling }

class PlayerController extends Pseudo3DComponent {
  int currentLane = 0; // -1, 0, 1
  static const double laneWidth = 2.5; // Match gate spacing
  static const double moveSpeed = 10.0;

  double targetX = 0;

  // Reaction state
  PlayerReaction _reaction = PlayerReaction.normal;
  double _reactionTimer = 0.0;

  // Speed multipliers
  double get speedMultiplier {
    switch (_reaction) {
      case PlayerReaction.boosted:
        return 1.15; // +15%
      case PlayerReaction.stumbling:
        return 0.70; // -30%
      case PlayerReaction.normal:
        return 1.0;
    }
  }

  PlayerController()
      : super(worldX: 0, worldY: 2.5, worldZ: -5.0); // Y: 2.5 for bottom

  late CharacterSprite _characterSprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _characterSprite = CharacterSprite()..position = Vector2(-0.4, -1.2);
    add(_characterSprite);
  }

  @override
  void update(double dt) {
    // Handle reaction timer
    if (_reactionTimer > 0) {
      _reactionTimer -= dt;
      if (_reactionTimer <= 0) {
        _reaction = PlayerReaction.normal;
        _reactionTimer = 0;
      }
    }

    // Apply visual feedback based on reaction
    if (_reaction == PlayerReaction.stumbling) {
      // Shake effect
      _characterSprite.position = Vector2(
        -0.4 + ((_reactionTimer * 20) % 0.1 - 0.05),
        -1.2,
      );
    } else if (_reaction == PlayerReaction.boosted) {
      // Glow effect (reset position)
      _characterSprite.position = Vector2(-0.4, -1.2);
    } else {
      _characterSprite.position = Vector2(-0.4, -1.2);
    }

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
    worldX = worldX.clamp(-2.5, 2.5);

    super.update(dt);
  }

  void moveLeft() {
    if (currentLane > -1) {
      currentLane--;
      currentLane = currentLane.clamp(-1, 1);
      targetX = currentLane * laneWidth;
    }
  }

  void moveRight() {
    if (currentLane < 1) {
      currentLane++;
      currentLane = currentLane.clamp(-1, 1);
      targetX = currentLane * laneWidth;
    }
  }

  /// Called when player answers correctly
  void triggerBoost() {
    _reaction = PlayerReaction.boosted;
    _reactionTimer = 2.0; // 2 seconds boost
  }

  /// Called when player answers incorrectly
  void triggerStumble() {
    _reaction = PlayerReaction.stumbling;
    _reactionTimer = 1.0; // 1 second stumble
  }
}
