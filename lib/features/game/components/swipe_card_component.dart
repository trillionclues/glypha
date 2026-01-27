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

  late _EnhancedCardBackground _background;
  late _GradientOverlay _choiceOverlay;
  late TextComponent _choiceLabel;

  bool _isDragging = false;
  final double _swipeThreshold = 120.0;
  Vector2 _initialPosition = Vector2.zero();

  String get _leftOption =>
      question.options.isNotEmpty ? question.options[0] : 'FALSE';
  String get _rightOption =>
      question.options.length > 1 ? question.options[1] : 'TRUE';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initialPosition = position.clone();

    add(RectangleComponent(
      size: size * 1.02,
      position: Vector2(0, 20),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    ));

    _background = _EnhancedCardBackground(
      size: size,
      radius: 28.0,
    );
    add(_background);

    add(TextComponent(
      text: 'QUESTION',
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color(0xFF667EEA).withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 3.0,
        ),
      ),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.center,
    ));

    final boxConfig = TextBoxConfig(
      maxWidth: size.x - 80,
      timePerChar: 0.05,
      growingBox: true,
      margins: const EdgeInsets.all(0),
    );

    final questionBox = TextBoxComponent(
      text: question.prompt,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF1A202C),
          fontSize: 26,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: 0.3,
          fontFamily: 'Roboto',
        ),
      ),
      boxConfig: boxConfig,
      align: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 20),
      anchor: Anchor.center,
      size: Vector2(size.x - 80, size.y * 0.5),
    );
    add(questionBox);

    _choiceOverlay = _GradientOverlay(
      size: size,
      radius: 28.0,
    );
    add(_choiceOverlay);

    _choiceLabel = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      priority: 10,
    );
    add(_choiceLabel);

    add(TextComponent(
      text: '← $_leftOption  |  $_rightOption →',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y - 30),
      anchor: Anchor.center,
    ));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    priority = 100;

    add(ScaleEffect.to(
      Vector2.all(1.06),
      EffectController(duration: 0.15, curve: Curves.easeOut),
    ));

    add(MoveEffect.by(
      Vector2(0, -5),
      EffectController(duration: 0.15, curve: Curves.easeOut),
    ));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging) return;

    position.add(event.localDelta);

    final dx = position.x - _initialPosition.x;

    angle = (dx / 400) * 0.4;

    final normalized = (dx / _swipeThreshold).clamp(-1.0, 1.0);
    final absVal = normalized.abs();

    if (normalized > 0.15) {
      _choiceOverlay.updateGradient(true);
      _choiceOverlay.opacity = absVal * 0.85;
      _choiceLabel.text = _rightOption.toUpperCase();
      _choiceLabel.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(math.min(absVal * 1.2, 1.0)),
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              color: Colors.black38,
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
      );
    } else if (normalized < -0.15) {
      // Left -> First option
      _choiceOverlay.updateGradient(false);
      _choiceOverlay.opacity = absVal * 0.85;
      _choiceLabel.text = _leftOption.toUpperCase();
      _choiceLabel.textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(math.min(absVal * 1.2, 1.0)),
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          shadows: [
            Shadow(
              color: Colors.black38,
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
      );
    } else {
      _choiceOverlay.opacity = 0;
      _choiceLabel.text = '';
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;

    final dx = position.x - _initialPosition.x;

    if (dx.abs() > _swipeThreshold) {
      final isRight = dx > 0;
      _animateOut(isRight);
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    add(MoveEffect.to(
      _initialPosition,
      EffectController(duration: 0.35, curve: Curves.elasticOut),
    ));
    add(RotateEffect.to(
      0,
      EffectController(duration: 0.35, curve: Curves.easeOut),
    ));
    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.25, curve: Curves.easeOut),
    ));

    _choiceOverlay.opacity = 0;
    _choiceLabel.text = '';
  }

  void _animateOut(bool isRight) {
    final targetX = isRight ? 1200.0 : -1200.0;
    final targetRotation = isRight ? 0.6 : -0.6;

    add(MoveEffect.to(
      Vector2(targetX, position.y + 150),
      EffectController(duration: 0.4, curve: Curves.easeInCubic),
    ));

    add(RotateEffect.to(
      targetRotation,
      EffectController(duration: 0.4, curve: Curves.easeInCubic),
    ));

    add(ScaleEffect.to(
      Vector2.all(0.8),
      EffectController(duration: 0.35, curve: Curves.easeIn),
      onComplete: () {
        int userIndex = isRight ? 1 : 0;
        bool isCorrect = (userIndex == question.correctIndex);

        onResult(isCorrect);
        removeFromParent();
      },
    ));
  }
}

class _EnhancedCardBackground extends PositionComponent {
  final double radius;

  _EnhancedCardBackground({
    required Vector2 size,
    required this.radius,
  }) : super(size: size);

  @override
  void render(ui.Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(radius),
    );

    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.y),
      [
        Colors.white,
        const Color(0xFFFAFAFA),
      ],
    );

    canvas.drawRRect(
      rrect,
      Paint()..shader = gradient,
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}

// Gradient overlay for swipe feedback
class _GradientOverlay extends PositionComponent {
  final double radius;
  double opacity = 0;
  bool isTrue = true;

  _GradientOverlay({
    required Vector2 size,
    required this.radius,
  }) : super(size: size);

  void updateGradient(bool isTrueDirection) {
    isTrue = isTrueDirection;
  }

  @override
  void render(ui.Canvas canvas) {
    if (opacity <= 0) return;

    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(radius),
    );

    final colors = isTrue
        ? [
            const Color(0xFF10B981).withOpacity(opacity * 0.6),
            const Color(0xFF059669).withOpacity(opacity * 0.8),
          ]
        : [
            const Color(0xFFEF4444).withOpacity(opacity * 0.6),
            const Color(0xFFDC2626).withOpacity(opacity * 0.8),
          ];

    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(size.x, size.y),
      colors,
    );

    canvas.drawRRect(rrect, Paint()..shader = gradient);
  }
}
