import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/player_controller.dart';
import '../components/world_manager.dart';
import '../components/gate_component.dart';
import '../components/horizon_component.dart';
import '../components/question_banner.dart';
import 'game_state.dart';
import 'package:flame/components.dart';
import 'package:glypha/features/game/data/repositories/question_repository.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';

class RunnerGame extends FlameGame with PanDetector {
  final WidgetRef ref;
  late PlayerController player;
  late WorldManager worldManager;
  late QuestionBanner questionBanner;

  // Swipe detection
  Vector2? _panStart;
  bool _hasSwiped = false;

  RunnerGame(this.ref);

  double get currentSpeed => ref.read(gameStateProvider).currentSpeed;

  @override
  Color backgroundColor() => const Color(0xFF111111);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;

    worldManager = WorldManager();
    player = PlayerController();
    questionBanner = QuestionBanner();

    add(HorizonComponent());
    add(questionBanner);

    world.add(worldManager);
    world.add(player);

    // Fetch live questions from Firestore
    try {
      final repository = ref.read(questionRepositoryProvider);
      final questions = await repository.getQuestionsByType(QuestionType.mcq);

      if (questions.isNotEmpty) {
        worldManager.setQuestions(questions);
        // Wait a frame before updating first question
        await Future.delayed(const Duration(milliseconds: 100));
        _updateQuestionForNextGate();
      } else {
        print('No MCQ questions available currently!');
        throw Exception('No MCQ questions available currently!');
      }
    } catch (e) {
      print('Error fetching questions: $e');
      endGame();
    }
  }

  void updateQuestion(String question, int answerCount) {
    questionBanner.setQuestion(question);
    player.setLaneConstraints(answerCount);
  }

  bool get isGameOver => ref.read(gameStateProvider).isGameOver;

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    final gatesToRemove = <GateComponent>[];

    for (final child in worldManager.children) {
      if (child is GateComponent && !child.hasCollided) {
        // More generous collision detection - check if gate is at or behind player
        if (child.worldZ <= player.worldZ + 0.5 &&
            child.worldZ >= player.worldZ - 2.0) {
          _handleGateCollision(child);
          gatesToRemove.add(child);
        }
      }
    }

    // Remove collided gates and update question
    for (final gate in gatesToRemove) {
      gate.removeFromParent();
    }

    if (gatesToRemove.isNotEmpty) {
      _updateQuestionForNextGate();
    }
  }

  void _updateQuestionForNextGate() {
    // Use WorldManager's method to get next gate
    final nextGate = worldManager.getNextGate();

    if (nextGate != null) {
      print('Updating banner for next gate: ${nextGate.question}');
      updateQuestion(nextGate.question, nextGate.answers.length);
    } else {
      print('No next gate found');
    }
  }

  void _handleGateCollision(GateComponent gate) {
    final playerAnswerIndex = player.getAnswerIndex();

    if (playerAnswerIndex < 0 || playerAnswerIndex >= gate.answers.length) {
      return;
    }

    final isCorrect = playerAnswerIndex == gate.correctAnswerIndex;
    gate.showFeedback(player.currentLane, isCorrect);

    if (isCorrect) {
      ref.read(gameStateProvider.notifier).incrementScore();
      ref.read(gameStateProvider.notifier).increaseSpeed();
      player.triggerBoost();
    } else {
      ref.read(gameStateProvider.notifier).loseLife();
      ref.read(gameStateProvider.notifier).decreaseSpeed();
      player.triggerStumble();
    }
  }

  void endGame() {
    Future.microtask(() {
      ref.read(gameStateProvider.notifier).setGameOver();
    });
  }

  @override
  void onPanStart(DragStartInfo info) {
    _panStart = info.eventPosition.global;
    _hasSwiped = false;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_panStart == null || _hasSwiped) return;

    final delta = info.eventPosition.global - _panStart!;
    const threshold = 40.0; // Minimum swipe distance in pixels

    // Detect horizontal swipe
    if (delta.x.abs() > threshold && delta.x.abs() > delta.y.abs() * 1.5) {
      _hasSwiped = true;

      if (delta.x > 0) {
        player.moveRight();
      } else {
        player.moveLeft();
      }
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _panStart = null;
    _hasSwiped = false;
  }
}
