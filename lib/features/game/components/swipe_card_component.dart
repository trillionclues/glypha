import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class SwipeCardComponent extends PositionComponent with DragCallbacks {
  final Question question;
  final Function(bool isCorrect) onResult;

  SwipeCardComponent({
    required this.question,
    required this.onResult,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  late RectangleComponent _background;
  late TextComponent _questionText;
  late TextComponent _trueLabelLarge;
  late TextComponent _falseLabelLarge;
  late RectangleComponent _overlay;
  late CircleComponent _trueIcon;
  late CircleComponent _falseIcon;

  bool _isDragging = false;
  final double _swipeThreshold = 100.0;
  Vector2 _initialPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _initialPosition = position.clone();

    final shadow = RectangleComponent(
      size: size,
      position: Vector2(0, 8),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    add(shadow);

    _background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    add(_background);

    final gradientOverlay = _GradientRectComponent(
      size: size,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x10667EEA),
          Color(0x10764BA2),
        ],
      ),
    );
    add(gradientOverlay);

    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFFE8E8E8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(border);

    final questionIcon = CircleComponent(
      radius: 30,
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF667EEA).withOpacity(0.1),
    );
    add(questionIcon);

    final questionMark = TextComponent(
      text: '?',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF667EEA),
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
    );
    add(questionMark);

    _questionText = TextComponent(
      text: _wrapText(question.prompt, 35),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(_questionText);

    // TRUE indicator (right side)
    _trueIcon = CircleComponent(
      radius: 50,
      position: Vector2(size.x - 60, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.green.withOpacity(0.0),
    );
    add(_trueIcon);

    _trueLabelLarge = TextComponent(
      text: '✓',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.0),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x - 60, size.y / 2),
      anchor: Anchor.center,
    );
    add(_trueLabelLarge);

    // FALSE indicator (left side)
    _falseIcon = CircleComponent(
      radius: 50,
      position: Vector2(60, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.red.withOpacity(0.0),
    );
    add(_falseIcon);

    _falseLabelLarge = TextComponent(
      text: '✗',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.0),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(60, size.y / 2),
      anchor: Anchor.center,
    );
    add(_falseLabelLarge);

    _overlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.transparent,
    );
    add(_overlay);

    final hintText = TextComponent(
      text: '← Swipe to answer →',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      position: Vector2(size.x / 2, size.y - 40),
      anchor: Anchor.center,
    );
    add(hintText);
  }

  String _wrapText(String text, int maxLineLength) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (var word in words) {
      if ((currentLine + word).length <= maxLineLength) {
        currentLine += '$word ';
      } else {
        if (currentLine.isNotEmpty) lines.add(currentLine.trim());
        currentLine = '$word ';
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine.trim());

    return lines.join('\n');
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    priority = 100;

    add(
      ScaleEffect.to(
        Vector2.all(1.03),
        EffectController(duration: 0.15),
      ),
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging) return;

    position.add(event.localDelta);

    final distanceFromCenter = position.x - _initialPosition.x;
    angle = (distanceFromCenter / 400) * 0.4;

    final normalizedDistance =
        (distanceFromCenter / _swipeThreshold).clamp(-1.0, 1.0);
    final absDistance = normalizedDistance.abs();

    if (normalizedDistance > 0.2) {
      // Swiping right (TRUE)
      final opacity = math.min(absDistance, 0.9);

      _overlay.paint.color = Colors.green.withOpacity(opacity * 0.15);
      _trueIcon.paint.color = Colors.green.withOpacity(opacity);
      _trueLabelLarge.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(opacity),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      );

      _falseIcon.paint.color = Colors.red.withOpacity(0.0);
      _falseLabelLarge.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.0),
          fontSize: 48,
        ),
      );
    } else if (normalizedDistance < -0.2) {
      // Swiping left (FALSE)
      final opacity = math.min(absDistance, 0.9);

      _overlay.paint.color = Colors.red.withOpacity(opacity * 0.15);
      _falseIcon.paint.color = Colors.red.withOpacity(opacity);
      _falseLabelLarge.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(opacity),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      );

      _trueIcon.paint.color = Colors.green.withOpacity(0.0);
      _trueLabelLarge.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.0),
          fontSize: 48,
        ),
      );
    } else {
      // Neutral state
      _overlay.paint.color = Colors.transparent;
      _trueIcon.paint.color = Colors.green.withOpacity(0.15);
      _falseIcon.paint.color = Colors.red.withOpacity(0.15);

      _trueLabelLarge.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 48,
        ),
      );
      _falseLabelLarge.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 48,
        ),
      );
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;

    final distanceFromCenter = position.x - _initialPosition.x;

    if (distanceFromCenter.abs() > _swipeThreshold) {
      bool swipedRight = distanceFromCenter > 0;
      _animateOffScreen(swipedRight);
    } else {
      _resetPosition();
    }
  }

  void _animateOffScreen(bool swipedRight) {
    final direction = swipedRight ? 1 : -1;
    final targetX = _initialPosition.x + (direction * 1200);
    final targetY = position.y + 100;

    add(
      MoveEffect.to(
        Vector2(targetX, targetY),
        EffectController(duration: 0.35, curve: Curves.easeInCubic),
        onComplete: () {
          _handleResult(swipedRight);
        },
      ),
    );

    add(
      RotateEffect.by(
        direction * 0.5,
        EffectController(duration: 0.35),
      ),
    );
  }

  void _handleResult(bool swipedRight) {
    bool isCorrect = (swipedRight && question.correctIndex == 1) ||
        (!swipedRight && question.correctIndex == 0);

    onResult(isCorrect);
    removeFromParent();
  }

  void _resetPosition() {
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.2),
      ),
    );

    add(
      MoveEffect.to(
        _initialPosition,
        EffectController(duration: 0.25, curve: Curves.easeOutBack),
      ),
    );

    add(
      RotateEffect.to(
        0,
        EffectController(duration: 0.25),
      ),
    );

    _overlay.paint.color = Colors.transparent;
    _trueIcon.paint.color = Colors.green.withOpacity(0.15);
    _falseIcon.paint.color = Colors.red.withOpacity(0.15);

    _trueLabelLarge.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 48,
      ),
    );
    _falseLabelLarge.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 48,
      ),
    );

    priority = 0;
  }
}

class _GradientRectComponent extends PositionComponent {
  final Gradient gradient;

  _GradientRectComponent({
    required Vector2 size,
    required this.gradient,
  }) : super(size: size);

  @override
  void render(ui.Canvas canvas) {
    final rect = size.toRect();
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
