import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import '../logic/stack_attack_game.dart';

class FallingBlockComponent extends PositionComponent
    with DragCallbacks, HasGameRef<StackAttackGame> {
  final Question question;
  final double fallSpeed;
  final Function(FallingBlockComponent block, Vector2 position) onLanded;

  FallingBlockComponent({
    required this.question,
    required this.fallSpeed,
    required this.onLanded,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  late RectangleComponent _background;
  late TextComponent _textComponent;

  bool _isDragging = false;
  bool _hasLanded = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Block Background
    _background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    add(_background);

    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    ));

    final cleanText = question.prompt.replaceAll('Category: ', '');

    _textComponent = TextComponent(
      text: cleanText,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hasLanded) return;

    // Gravity
    if (!_isDragging) {
      position.y += fallSpeed * dt;
    }

    // Check if hit the floor (approximate bucket height)
    if (position.y >= gameRef.size.y - 60) {
      _hasLanded = true;
      onLanded(this, position);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_hasLanded) return;
    _isDragging = true;
    priority = 100;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging || _hasLanded) return;

    // Only allow horizontal dragging
    position.x += event.localDelta.x;

    // Clamp to screen bounds
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    priority = 0;
  }
}
