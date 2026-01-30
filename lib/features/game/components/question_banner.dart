import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/runner_game.dart';

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

    const topMargin = 90.0;
    canvas.drawRect(
      Rect.fromLTWH(0, topMargin, size.x, 100),
      Paint()..color = Colors.black.withOpacity(0.7),
    );

    // Draw question text
    String displayQuestion = currentQuestion;
    if (displayQuestion.length > 120) {
      displayQuestion = '${displayQuestion.substring(0, 117)}...';
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayQuestion,
        style: TextStyle(
          color: Colors.white,
          fontSize: displayQuestion.length > 80 ? 15 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
      ellipsis: '...',
    );

    textPainter.layout(maxWidth: size.x - 40);
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, topMargin + 35),
    );
  }
}
