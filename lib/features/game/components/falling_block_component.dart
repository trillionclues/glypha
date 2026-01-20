import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import '../logic/stack_attack_game.dart';
import 'dart:ui' as ui;

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

  late TextComponent _textComponent;
  bool _isDragging = false;
  bool _hasLanded = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 1. Crate Body (Cyber Box)
    final cratePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final crateBorder = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    add(_CrateShapeComponent(
      size: size,
      fill: cratePaint,
      border: crateBorder,
    ));

    // 2. Text (Cleaned)
    final cleanText = question.prompt
        .replaceAll('Category: ', '')
        .replaceAll('Synonym for ', '')
        .replaceAll('Opposite of ', '');

    _textComponent = TextComponent(
      text: cleanText,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16, // Smaller for crate
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
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

    if (!_isDragging) {
      position.y += fallSpeed * dt;
    }

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
    scale = Vector2.all(1.1); // Graphic pop
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging || _hasLanded) return;
    position.x += event.localDelta.x;
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    priority = 0;
    scale = Vector2.all(1.0);
  }
}

class _CrateShapeComponent extends PositionComponent {
  final Paint fill;
  final Paint border;

  _CrateShapeComponent({
    required Vector2 size,
    required this.fill,
    required this.border,
  }) : super(size: size);

  @override
  void render(ui.Canvas canvas) {
    final rect = size.toRect();
    // Chamfered corners
    final path = Path()
      ..moveTo(10, 0)
      ..lineTo(size.x - 10, 0)
      ..lineTo(size.x, 10)
      ..lineTo(size.x, size.y - 10)
      ..lineTo(size.x - 10, size.y)
      ..lineTo(10, size.y)
      ..lineTo(0, size.y - 10)
      ..lineTo(0, 10)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);

    // Tech lines (decorative)
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(10, 10), Offset(size.x - 10, 10), detailPaint);
    canvas.drawLine(
        Offset(10, size.y - 10), Offset(size.x - 10, size.y - 10), detailPaint);
  }
}
