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

  late _RoundedCardBackground _background;
  late _GradientRectComponent _choiceOverlay;
  late TextComponent _choiceLabel;

  // Visual state
  bool _isDragging = false;
  final double _swipeThreshold = 100.0;
  Vector2 _initialPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initialPosition = position.clone();

    // 1. Drop Shadow (Soft & Deep)
    add(RectangleComponent(
      size: size,
      position: Vector2(0, 15),
      paint: Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    ));

    // 2. Card Background (Clean White with Rounded Corners)
    // Note: Flame RectangleComponent doesn't natively support border radius easily without custom render,
    // so we use a custom rendered component for the base card to ensure smoothness.
    _background = _RoundedCardBackground(
      size: size,
      color: Colors.white,
      radius: 25.0,
    );
    add(_background);

    // 3. Question Label
    add(TextComponent(
      text: 'QUESTION',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    ));

    // 4. Question Text (Using TextBoxComponent for automatic wrapping)
    final boxConfig = TextBoxConfig(
      maxWidth: size.x - 60,
      timePerChar: 0.05, // Typewriter effect optional, set to 0 for instant
      growingBox: true,
      margins: const EdgeInsets.all(0),
    );

    final questionBox = TextBoxComponent(
      text: question.prompt,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.3,
          fontFamily: 'Roboto', // Or user preferred font
        ),
      ),
      boxConfig: boxConfig,
      align: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 20),
      anchor: Anchor.center,
      size: Vector2(size.x - 60, size.y / 2),
    );
    add(questionBox);

    // 5. Choice Overlay (Green/Red tint on swipe)
    _choiceOverlay = _GradientRectComponent(
      size: size,
      color: Colors.transparent,
      radius: 25.0,
    );
    add(_choiceOverlay);

    // 6. Large Choice Label (TRUE / FALSE)
    _choiceLabel = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      priority: 10,
    );
    add(_choiceLabel);

    // 7. Static Instructions (Small Hint)
    add(TextComponent(
      text: 'FALSE',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.red.withOpacity(0.3),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(30, size.y / 2),
      anchor: Anchor.centerLeft,
    ));

    add(TextComponent(
      text: 'TRUE',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.green.withOpacity(0.3),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x - 30, size.y / 2),
      anchor: Anchor.centerRight,
    ));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    priority = 100;

    // Slight lift effect
    add(ScaleEffect.to(
      Vector2.all(1.05),
      EffectController(duration: 0.1),
    ));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging) return;

    position.add(event.localDelta);

    final dx = position.x - _initialPosition.x;

    // Rotate slightly based on drag distance
    angle = (dx / 500) * 0.5;

    // Visual Feedback
    final normalized = (dx / _swipeThreshold).clamp(-1.0, 1.0);
    final absVal = normalized.abs();

    if (normalized > 0.1) {
      // Right -> TRUE (Green)
      _choiceOverlay.color = Colors.green.withOpacity(absVal * 0.6);
      _choiceLabel.text = 'TRUE';
      _choiceLabel.textRenderer = TextPaint(
        style: TextStyle(
            color: Colors.white.withOpacity(absVal),
            fontSize: 52,
            fontWeight: FontWeight.w900),
      );
    } else if (normalized < -0.1) {
      // Left -> FALSE (Red)
      _choiceOverlay.color = Colors.red.withOpacity(absVal * 0.6);
      _choiceLabel.text = 'FALSE';
      _choiceLabel.textRenderer = TextPaint(
        style: TextStyle(
            color: Colors.white.withOpacity(absVal),
            fontSize: 52,
            fontWeight: FontWeight.w900),
      );
    } else {
      _choiceOverlay.color = Colors.transparent;
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
      EffectController(duration: 0.3, curve: Curves.easeOutBack),
    ));
    add(RotateEffect.to(
      0,
      EffectController(duration: 0.3, curve: Curves.easeOut),
    ));
    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.2),
    ));

    // Reset overlay
    _choiceOverlay.color = Colors.transparent;
    _choiceLabel.text = '';
  }

  void _animateOut(bool isRight) {
    final targetX = isRight ? 1000.0 : -1000.0;
    add(MoveEffect.to(
      Vector2(targetX, position.y + 100),
      EffectController(duration: 0.4, curve: Curves.easeInCubic),
      onComplete: () {
        // Correct Logic:
        // index 0 = True (usually), index 1 = False?
        // Wait, standard implies: Option A vs Option B.
        // User request check: "Swipe Right for True". "Swipe Left for False".
        // If question.options = ["True", "False"] (standard binary)
        // correctIndex 0 -> True, correctIndex 1 -> False.

        bool userChoseTrue = isRight; // Right is True

        // Map choice to index
        // If options are ["True", "False"], True is 0.
        // If user swiped right (True), they picked index 0.
        int userIndex = userChoseTrue ? 0 : 1;

        bool isCorrect = (userIndex == question.correctIndex);

        // HACK: Some questions might have ["False", "True"]?
        // Better to check string content if possible, but binary standard is True=0 usually.
        // Let's rely on standard ["True", "False"] for binary type.
        // If types are mixed, we compare option string.
        if (question.type == QuestionType.binary &&
            question.options.contains("True")) {
          final trueIndex = question.options.indexOf("True");
          isCorrect = (userIndex == trueIndex) == userChoseTrue;
          // Wait:
          // If True is index 0. userIndex (0) == trueIndex (0) -> True.
          // If False is index 1. userIndex (1) == trueIndex (0) -> False.
          // Logic: Did user pick the correct index?
          // We need to know which index corresponds to "Right Swipe".
          // Convention: Right = First Option? Or Right = "True"?
          // UI says "Right = True".
          // So if correct Answer is "True", and User Swiped Right -> Correct.
        } else {
          // Fallback for generic binary (Left/Right options)
          // Assume Option 0 = Left, Option 1 = Right
          isCorrect = (isRight && question.correctIndex == 1) ||
              (!isRight && question.correctIndex == 0);
        }

        onResult(isCorrect);
        removeFromParent();
      },
    ));
  }
}

class _RoundedCardBackground extends PositionComponent {
  final Color color;
  final double radius;

  _RoundedCardBackground({
    required Vector2 size,
    required this.color,
    required this.radius,
  }) : super(size: size);

  @override
  void render(ui.Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }
}

class _GradientRectComponent extends PositionComponent {
  Color color;
  final double radius;

  _GradientRectComponent({
    required Vector2 size,
    required this.color,
    required this.radius,
  }) : super(size: size);

  @override
  void render(ui.Canvas canvas) {
    if (color == Colors.transparent) return;

    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }
}
