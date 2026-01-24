import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show Colors, debugPrint;
import '../components/falling_block_component.dart';
import '../components/sorting_bucket_component.dart';
import '../data/repositories/question_repository.dart';
import '../domain/entities/question_entity.dart';
import 'game_state.dart';
import 'package:glypha/features/home/presentation/provider/level_provider.dart';

class StackAttackGame extends FlameGame {
  final WidgetRef ref;
  final String? levelId;

  StackAttackGame(this.ref, {this.levelId});

  List<Question> _questions = [];
  int _currentIndex = 0;
  double _baseFallSpeed = 150.0;
  double _spawnTimer = 0;
  double _spawnInterval = 1.5;

  final List<SortingBucketComponent> _buckets = [];

  @override
  Color backgroundColor() => const Color(0xFFF0F4F8);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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
        final allMcq = await repository.getQuestionsByType(QuestionType.mcq);
        _questions = allMcq.where((q) => q.options.length == 2).toList();

        if (_questions.isEmpty) {
          _questions = allMcq
              .where((q) =>
                  q.prompt.toLowerCase().contains('category') ||
                  q.id.contains('stack'))
              .toList();
        }
      }

      if (_questions.isNotEmpty) {
        _setupBuckets();
        _spawnBlock();
      } else {
        debugPrint('No questions found for Stack Attack');
        _endGame();
      }
    } catch (e) {
      debugPrint('Error loading Stack Attack: $e');
      _endGame();
    }
  }

  void _setupBuckets() {
    final categories = _questions[0].options;
    final bucketWidth = size.x / categories.length;
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];

    for (int i = 0; i < categories.length; i++) {
      final bucket = SortingBucketComponent(
        category: categories[i],
        color: colors[i % colors.length],
        size: Vector2(bucketWidth - 10, 60),
        position: Vector2((i * bucketWidth) + bucketWidth / 2, size.y - 30),
      );
      _buckets.add(bucket);
      add(bucket);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (ref.read(gameStateProvider).isGameOver) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnBlock();
      // Gradually speed up
      _spawnInterval = math.max(1.2, _spawnInterval * 0.98);
    }
  }

  void _spawnBlock() {
    if (_currentIndex >= _questions.length) {
      _endGame(isVictory: true);
      return;
    }

    final question = _questions[_currentIndex];
    final randomX = 50 + math.Random().nextDouble() * (size.x - 100);

    final block = FallingBlockComponent(
      question: question,
      fallSpeed: ref.read(gameStateProvider).currentSpeed,
      size: Vector2(100, 60),
      position: Vector2(randomX, -50),
      onLanded: (block, pos) {
        _checkSort(block, pos);
      },
    );
    add(block);
    _currentIndex++;
  }

  void _checkSort(FallingBlockComponent block, Vector2 pos) {
    final bucket = _buckets.firstWhere(
      (b) => b.category == block.question.options[block.question.correctIndex],
      orElse: () => _buckets[0],
    );

    final isCorrect = (pos.x - bucket.position.x).abs() < bucket.size.x / 2;

    final gameState = ref.read(gameStateProvider.notifier);
    if (isCorrect) {
      gameState.incrementScore();
    } else {
      gameState.loseLife();
    }

    block.removeFromParent();
  }

  void _endGame({bool isVictory = false}) {
    final notifier = ref.read(gameStateProvider.notifier);
    if (isVictory) {
      notifier.winGame();
    } else {
      notifier.setGameOver();
    }
  }
}
