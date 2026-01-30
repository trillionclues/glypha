import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/swipe_card_component.dart';
import '../data/repositories/question_repository.dart';
import '../domain/entities/question_entity.dart';
import 'game_state.dart';
import 'package:glypha/features/home/presentation/provider/level_provider.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';

class SwipeMasterGame extends FlameGame {
  final WidgetRef ref;
  final String? levelId;

  SwipeMasterGame(this.ref, {this.levelId});

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
      if (levelId != null) {
        final levelData = await ref.read(virtualLevelProvider(levelId!).future);
        if (levelData != null) {
          _questions = levelData.questions;
        }
      }

      if (_questions.isEmpty) {
        final repository = ref.read(questionRepositoryProvider);
        final authState = ref.read(authNotifierProvider);
        final userId =
            authState is AuthAuthenticated ? authState.user.id : 'anonymous';
        _questions = await repository.getQuestionsByTypeForUser(
            QuestionType.binary, userId);
      }

      if (_questions.isEmpty) {
        debugPrint('No binary questions found');
        return;
      }

      // Limit to desired number of questions
      if (_questions.length > _totalQuestions) {
        _questions = _questions.take(_totalQuestions).toList();
      } else {
        _totalQuestions = _questions.length;
      }

      // Initialize game state with total questions for dynamic scoring
      ref
          .read(gameStateProvider.notifier)
          .startGame(_questions.map((q) => q.id).toList());
      _updateProgress();
      _spawnNextCard();
    } catch (e) {
      debugPrint('Error loading SwipeMaster: $e');
    }
  }

  void _spawnNextCard() {
    if (_currentIndex >= _questions.length) {
      _finishGame(true);
      return;
    }

    final question = _questions[_currentIndex];
    final card = SwipeCardComponent(
      question: question,
      onResult: _handleResult,
      size: Vector2(size.x * 0.85, size.y * 0.55),
      position: Vector2(size.x / 2, size.y / 2 + 50),
    );
    add(card);
  }

  void _handleResult(bool isCorrect) {
    final gameState = ref.read(gameStateProvider.notifier);
    if (isCorrect) {
      gameState.incrementScore(_questions[_currentIndex].id);
    } else {
      gameState.loseLife();
      // Check if game over
      if (ref.read(gameStateProvider).isGameOver) {
        return;
      }
    }

    _currentIndex++;
    _updateProgress();
    _spawnNextCard();
  }

  void _updateProgress() {
    _progressText.text = '${_currentIndex + 1} / $_totalQuestions';
    final progress = _currentIndex / _totalQuestions;
    _progressFill.size.x = (size.x - 80) * progress;
  }

  void _finishGame(bool isVictory) {
    if (isVictory) {
      ref.read(gameStateProvider.notifier).winGame();
    } else {
      ref.read(gameStateProvider.notifier).setGameOver();
    }
  }
}
