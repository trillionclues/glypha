import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/swipe_card_component.dart';
import '../data/repositories/question_repository.dart';
import '../domain/entities/question_entity.dart';
import 'game_state.dart';

class SwipeMasterGame extends FlameGame {
  final WidgetRef ref;

  SwipeMasterGame(this.ref);

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _totalQuestions = 20;

  late TextComponent _progressText;
  late RectangleComponent _progressBar;
  late RectangleComponent _progressFill;

  final List<RectangleComponent> _backgroundCards = [];

  @override
  Color backgroundColor() => const Color(0xFF0F172A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _progressBar = RectangleComponent(
      position: Vector2(40, 60),
      size: Vector2(size.x - 80, 8),
      paint: Paint()..color = const Color(0xFF1E293B),
    );
    add(_progressBar);

    _progressFill = RectangleComponent(
      position: Vector2(40, 60),
      size: Vector2(0, 8),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ).createShader(Rect.fromLTWH(0, 0, size.x - 80, 8)),
    );
    add(_progressFill);

    _progressText = TextComponent(
      text: '1 / $_totalQuestions',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      position: Vector2(size.x / 2, 90),
      anchor: Anchor.center,
    );
    add(_progressText);

    // Create background card stack (visual depth)
    for (int i = 0; i < 2; i++) {
      final offset = (i + 1) * 8.0;
      final scale = 1.0 - (i + 1) * 0.04;

      final bgCard = RectangleComponent(
        position: Vector2(
          size.x / 2 - (size.x * 0.85 * scale) / 2,
          size.y / 2 - (size.y * 0.55 * scale) / 2 + 50 + offset,
        ),
        size: Vector2(size.x * 0.85 * scale, size.y * 0.55 * scale),
        paint: Paint()
          ..color = const Color(0xFF1E293B).withOpacity(0.3 - i * 0.1),
      );
      add(bgCard);
      _backgroundCards.add(bgCard);
    }

    // Fetch questions
    try {
      final repository = ref.read(questionRepositoryProvider);
      _questions = await repository.getQuestionsByType(QuestionType.binary);

      if (_questions.isEmpty) {
        throw Exception('No binary questions found');
      }

      // Limit to desired number of questions
      if (_questions.length > _totalQuestions) {
        _questions = _questions.take(_totalQuestions).toList();
      } else {
        _totalQuestions = _questions.length;
      }

      _updateProgress();
      _spawnNextCard();
    } catch (e) {
      print('Error loading Swipe Master: $e');
      _showError();
    }
  }

  void _spawnNextCard() {
    if (_currentIndex >= _questions.length) {
      _endGame();
      return;
    }

    final question = _questions[_currentIndex];

    // Card size and position
    final cardWidth = size.x * 0.85;
    final cardHeight = size.y * 0.55;
    final cardPosition = Vector2(size.x / 2, size.y / 2 + 50);

    final card = SwipeCardComponent(
      question: question,
      size: Vector2(cardWidth, cardHeight),
      position: cardPosition,
      onResult: (isCorrect) {
        _handleResult(isCorrect);
        _currentIndex++;

        // Small delay before next card
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_currentIndex < _questions.length) {
            _updateProgress();
            _spawnNextCard();
          } else {
            _endGame();
          }
        });
      },
    );

    add(card);
  }

  void _updateProgress() {
    final progress = (_currentIndex + 1) / _totalQuestions;
    final fillWidth = (size.x - 80) * progress;

    _progressFill.size = Vector2(fillWidth, 8);
    _progressText.text = '${_currentIndex + 1} / $_totalQuestions';
  }

  void _handleResult(bool isCorrect) {
    if (isCorrect) {
      ref.read(gameStateProvider.notifier).incrementScore();
      _showFeedback(true);
    } else {
      ref.read(gameStateProvider.notifier).loseLife();
      _showFeedback(false);
    }
  }

  void _showFeedback(bool isCorrect) {
    final feedbackBg = RectangleComponent(
      position: Vector2(size.x / 2 - 150, size.y - 200),
      size: Vector2(300, 80),
      paint: Paint()
        ..color =
            (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                .withOpacity(0.95),
    );
    add(feedbackBg);

    final feedbackText = TextComponent(
      text: isCorrect ? '✓  Correct!' : '✗  Wrong',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y - 160),
      anchor: Anchor.center,
    );
    add(feedbackText);

    // Animate feedback
    // feedbackBg.add(
    //   OpacityEffect.fadeOut(
    //     EffectController(
    //       duration: 0.8,
    //       startDelay: 0.3,
    //     ),
    //   ),
    // );

    Future.delayed(const Duration(milliseconds: 1100), () {
      feedbackBg.removeFromParent();
      feedbackText.removeFromParent();
    });
  }

  void _showError() {
    final errorBg = RectangleComponent(
      position: Vector2(size.x / 2 - 150, size.y / 2 - 60),
      size: Vector2(300, 120),
      paint: Paint()..color = const Color(0xFF1E293B),
    );
    add(errorBg);

    final errorText = TextComponent(
      text: 'Failed to load\nquestions',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(errorText);

    Future.delayed(const Duration(seconds: 2), () {
      _endGame();
    });
  }

  void _endGame() {
    Future.microtask(() {
      ref.read(gameStateProvider.notifier).setGameOver();
    });
  }
}
