import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/runner_game.dart';

/// Fixed banner at top of screen showing the current question
class QuestionBanner extends PositionComponent with HasGameRef<RunnerGame> {
  String currentQuestion = '';

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = Vector2.zero();
    priority = 1000; // Always on top
  }

  void setQuestion(String question) {
    currentQuestion = question;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (currentQuestion.isEmpty) return;

    final size = gameRef.size;

    // Draw semi-transparent background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 120),
      Paint()..color = Colors.black.withOpacity(0.7),
    );

    // Draw question text
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentQuestion,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: size.x - 40);
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, 60),
    );
  }
}
