import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/player_controller.dart';
import '../components/world_manager.dart';
import '../components/gate_component.dart';
import '../components/horizon_component.dart';
import '../components/question_banner.dart';
import 'game_state.dart';
import 'package:flame/components.dart';

class RunnerGame extends FlameGame with HorizontalDragDetector {
  final WidgetRef ref;
  late PlayerController player;
  late WorldManager worldManager;
  late QuestionBanner questionBanner;

  RunnerGame(this.ref);

  double get currentSpeed => ref.read(gameStateProvider).currentSpeed;

  @override
  Color backgroundColor() => const Color(0xFF111111);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Center the camera
    camera.viewfinder.anchor = Anchor.center;

    worldManager = WorldManager();
    player = PlayerController();
    questionBanner = QuestionBanner();

    // Add horizon first (background)
    add(HorizonComponent());

    // Add question banner (UI overlay)
    add(questionBanner);

    world.add(worldManager);
    world.add(player);

    // Wait a frame for worldManager to spawn first gate, then show its question
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateQuestionForNextGate();
    });
  }

  void updateQuestion(String question) {
    questionBanner.setQuestion(question);
  }

  bool get isGameOver => ref.read(gameStateProvider).isGameOver;

  @override
  void update(double dt) {
    super.update(dt);

    // Stop processing collisions if game is over
    if (isGameOver) return;

    // Check collisions
    for (final child in worldManager.children) {
      if (child is GateComponent) {
        // Check if gate is passing player
        if ((child.worldZ - player.worldZ).abs() < 0.5) {
          // Collision!
          _handleGateCollision(child);
          // Remove gate immediately to avoid double collision
          child.removeFromParent();

          // Find the next gate and update question banner
          _updateQuestionForNextGate();
        }
      }
    }
  }

  void _updateQuestionForNextGate() {
    // Find the closest gate ahead
    GateComponent? nextGate;
    double closestZ = double.infinity;

    for (final child in worldManager.children) {
      if (child is GateComponent && child.worldZ > player.worldZ) {
        if (child.worldZ < closestZ) {
          closestZ = child.worldZ;
          nextGate = child;
        }
      }
    }

    if (nextGate != null) {
      updateQuestion(nextGate.question);
    }
  }

  void _handleGateCollision(GateComponent gate) {
    // Map player lane (-1, 0, 1) to answer index (0, 1, 2)
    final playerAnswerIndex = player.currentLane + 1;
    final isCorrect = playerAnswerIndex == gate.correctAnswerIndex;

    // Show visual feedback on the gate
    gate.showFeedback(player.currentLane, isCorrect);

    if (isCorrect) {
      // Correct!
      ref.read(gameStateProvider.notifier).incrementScore();
      ref.read(gameStateProvider.notifier).increaseSpeed();
      player.triggerBoost(); // Visual boost reaction
    } else {
      // Wrong!
      ref.read(gameStateProvider.notifier).loseLife();
      ref.read(gameStateProvider.notifier).decreaseSpeed();
      player.triggerStumble(); // Visual stumble reaction
    }
  }

  void endGame() {
    // Mark game as over
    ref.read(gameStateProvider.notifier).setGameOver();
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    final velocity = info.velocity.x;
    // Lower threshold for easier swiping
    if (velocity < -20) {
      onSwipeLeft();
    } else if (velocity > 20) {
      onSwipeRight();
    }
  }

  void onSwipeLeft() {
    player.moveLeft();
  }

  void onSwipeRight() {
    player.moveRight();
  }
}
