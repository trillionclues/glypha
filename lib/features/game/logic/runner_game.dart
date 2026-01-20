import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/player_controller.dart';
import '../components/world_manager.dart';
import '../components/horizon_component.dart';
import '../components/question_banner.dart';
import 'game_state.dart';
import 'package:flame/components.dart';
import 'package:glypha/features/game/data/repositories/question_repository.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'package:glypha/features/home/presentation/provider/level_provider.dart';

class RunnerGame extends FlameGame with PanDetector {
  final WidgetRef ref;
  final String? levelId;

  late PlayerController player;
  late WorldManager worldManager;
  late QuestionBanner questionBanner;

  // Swipe detection
  Vector2? _panStart;
  bool _hasSwiped = false;

  RunnerGame(this.ref, {this.levelId});

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
      List<Question> questions = [];

      if (levelId != null) {
        final levelData = await ref.read(virtualLevelProvider(levelId!).future);
        if (levelData != null) {
          questions = levelData.questions;
        }
      }

      if (questions.isEmpty) {
        final repository = ref.read(questionRepositoryProvider);
        questions = await repository.getQuestionsByType(QuestionType.mcq);
      }

      if (questions.isNotEmpty) {
        worldManager.setQuestions(questions);
        // Wait a frame before updating first question
        await Future.delayed(const Duration(milliseconds: 100));
        _updateQuestionForNextGate();
      } else {
        debugPrint('No MCQ questions available currently!');
      }
    } catch (e) {
      debugPrint('Error fetching questions: $e');
    }
  }

  void _updateQuestionForNextGate() {
    final state = ref.read(gameStateProvider);
    final questions = worldManager.questions;
    if (questions.isEmpty) return;

    // Use score/10 or something to determine question index if needed
    // For now we just use a simple index
    final index = (state.score).clamp(0, questions.length - 1);
    final nextQuestion = questions[index];
    questionBanner.setQuestion(nextQuestion.prompt);
  }

  @override
  void onPanStart(DragStartInfo info) {
    _panStart = Vector2(info.raw.globalPosition.dx, info.raw.globalPosition.dy);
    _hasSwiped = false;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_panStart == null || _hasSwiped) return;

    final diff = info.raw.globalPosition.dx - _panStart!.x;
    const threshold = 30.0;

    if (diff.abs() > threshold) {
      if (diff > 0) {
        player.moveRight();
      } else {
        player.moveLeft();
      }
      _hasSwiped = true;
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _panStart = null;
    _hasSwiped = false;
  }
}
