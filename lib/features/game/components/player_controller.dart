import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'pseudo_3d_component.dart';
import 'character_sprite.dart';

enum PlayerReaction { normal, boosted, stumbling }

class PlayerController extends Pseudo3DComponent {
  int currentLane = 0; // -1, 0, 1
  static const double laneWidth = 1.6;
  static const double moveSpeed = 15.0;

  double targetX = 0;

  int _maxLanes = 3;
  int _minLane = -1;
  int _maxLane = 1;

  PlayerReaction _reaction = PlayerReaction.normal;
  double _reactionTimer = 0.0;

  late RectangleComponent _swipeIndicatorLeft;
  late RectangleComponent _swipeIndicatorRight;
  double _indicatorOpacity = 0.0;

  double get speedMultiplier {
    switch (_reaction) {
      case PlayerReaction.boosted:
        return 1.15;
      case PlayerReaction.stumbling:
        return 0.70;
      case PlayerReaction.normal:
        return 1.0;
    }
  }

  PlayerController() : super(worldX: 0, worldY: 2.5, worldZ: -5.0);

  late CharacterSprite _characterSprite;
  late CircleComponent _selectionCircle;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Selection circle to show where the player is
    _selectionCircle = CircleComponent(
      radius: 0.7,
      position: Vector2(0, 0.2),
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.15,
    );
    add(_selectionCircle);

    _characterSprite = CharacterSprite()..position = Vector2(-0.4, -1.2);
    add(_characterSprite);

    _swipeIndicatorLeft = RectangleComponent(
      position: Vector2(-1.5, -0.5),
      size: Vector2(0.5, 1.0),
      paint: Paint()..color = Colors.white.withOpacity(0.0),
    );
    add(_swipeIndicatorLeft);

    _swipeIndicatorRight = RectangleComponent(
      position: Vector2(1.0, -0.5),
      size: Vector2(0.5, 1.0),
      paint: Paint()..color = Colors.white.withOpacity(0.0),
    );
    add(_swipeIndicatorRight);
  }

  void setLaneConstraints(int answerCount) {
    _maxLanes = answerCount;

    switch (answerCount) {
      case 1:
        _minLane = 0;
        _maxLane = 0;
        if (currentLane != 0) {
          currentLane = 0;
          targetX = 0;
        }
        break;
      case 2:
        _minLane = -1;
        _maxLane = 0;
        if (currentLane > 0) {
          currentLane = 0;
          targetX = _getLanePosition(currentLane);
        }
        break;
      case 3:
      default:
        _minLane = -1;
        _maxLane = 1;
        break;
    }
  }

  double _getLanePosition(int lane) {
    switch (_maxLanes) {
      case 1:
        return 0;
      case 2:
        return lane == -1 ? -0.8 : 0.8;
      case 3:
      default:
        return lane * laneWidth;
    }
  }

  int getAnswerIndex() {
    switch (_maxLanes) {
      case 1:
        return 0;
      case 2:
        return currentLane + 1;
      case 3:
      default:
        return currentLane + 1;
    }
  }

  @override
  void update(double dt) {
    if (_reactionTimer > 0) {
      _reactionTimer -= dt;
      if (_reactionTimer <= 0) {
        _reaction = PlayerReaction.normal;
        _reactionTimer = 0;
      }
    }

    if (_reaction == PlayerReaction.boosted) {
      _selectionCircle.paint.color = const Color(0xFF4CAF50).withOpacity(0.6);
    } else if (_reaction == PlayerReaction.stumbling) {
      _selectionCircle.paint.color = const Color(0xFFF44336).withOpacity(0.6);
    } else {
      _selectionCircle.paint.color = const Color(0xFF4CAF50).withOpacity(0.3);
    }

    if (_reaction == PlayerReaction.stumbling) {
      _characterSprite.position = Vector2(
        -0.4 + ((_reactionTimer * 20) % 0.1 - 0.05),
        -1.2,
      );
    } else {
      _characterSprite.position = Vector2(-0.4, -1.2);
    }

    final clampedTargetX = targetX.clamp(-2.5, 2.5);

    if ((worldX - clampedTargetX).abs() > 0.01) {
      final direction = (clampedTargetX - worldX).sign;
      worldX += direction * moveSpeed * dt;

      if ((clampedTargetX - worldX).sign != direction) {
        worldX = clampedTargetX;
      }
    } else {
      worldX = clampedTargetX;
    }

    if (_indicatorOpacity > 0) {
      _indicatorOpacity -= dt * 2.0;
      if (_indicatorOpacity < 0) _indicatorOpacity = 0;

      _swipeIndicatorLeft.paint.color =
          Colors.white.withOpacity(_indicatorOpacity * 0.5);
      _swipeIndicatorRight.paint.color =
          Colors.white.withOpacity(_indicatorOpacity * 0.5);
    }

    super.update(dt);
  }

  void moveLeft() {
    if (currentLane > _minLane) {
      currentLane--;
      currentLane = currentLane.clamp(_minLane, _maxLane);
      targetX = _getLanePosition(currentLane);
      _showSwipeIndicator(true);
    }
  }

  void moveRight() {
    if (currentLane < _maxLane) {
      currentLane++;
      currentLane = currentLane.clamp(_minLane, _maxLane);
      targetX = _getLanePosition(currentLane);
      _showSwipeIndicator(false);
    }
  }

  void _showSwipeIndicator(bool isLeft) {
    _indicatorOpacity = 1.0;
  }

  void triggerBoost() {
    _reaction = PlayerReaction.boosted;
    _reactionTimer = 2.0;
  }

  void triggerStumble() {
    _reaction = PlayerReaction.stumbling;
    _reactionTimer = 1.0;
  }
}
