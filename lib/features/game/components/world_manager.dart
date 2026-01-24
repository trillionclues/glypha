import 'dart:math';
import 'package:flame/components.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import '../logic/runner_game.dart';
import 'pseudo_3d_component.dart';
import 'gate_component.dart';
import '../logic/game_state.dart';

class WorldManager extends Component with HasGameRef<RunnerGame> {
  double spawnTimer = 0.0;
  final Random _random = Random();
  int currentQuestionIndex = 0;

  List<Question> _questions = [];
  bool _isInitialized = false;

  final List<GateComponent> _activeGates = [];

  List<Question> get questions => _questions;

  void setQuestions(List<Question> questions) {
    _questions = questions;
    _isInitialized = true;
    currentQuestionIndex = 0;
    _activeGates.clear();

    // Spawn first gate immediately
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isInitialized && currentQuestionIndex < _questions.length) {
        _spawnGate();
      }
    });
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isInitialized) return;

    final gameState = gameRef.ref.read(gameStateProvider);
    if (gameState.isGameOver) return;

    _activeGates.removeWhere((gate) => gate.isRemoved);

    final player = gameRef.player;
    final playerZ = player.worldZ;

    for (final child in children) {
      if (child is Pseudo3DComponent) {
        final speed = gameRef.currentSpeed;
        child.worldZ -= speed * dt;

        // Collision Check
        // Gate is "thick" (Z-depth assumed small), check if it passed player
        if (child is GateComponent && !child.hasCollided) {
          if (child.worldZ <= playerZ + 0.5 && child.worldZ >= playerZ - 0.5) {
            _handleCollision(child, player.currentLane);
          }
        }

        if (child.worldZ < Pseudo3DComponent.cameraZ - 10) {
          child.removeFromParent();
          if (child is GateComponent) {
            _activeGates.remove(child);
          }
        }
      }
    }

    spawnTimer += dt;

    // Only spawn if:
    // 1. Enough time has passed
    // 2. We have questions left
    // 3. We don't have too many active gates
    if (spawnTimer > 5.0 &&
        currentQuestionIndex < _questions.length &&
        _activeGates.length < 2) {
      spawnTimer = 0;
      _spawnGate();
    }

    final nextGate = getNextGate();
    if (nextGate != null &&
        gameRef.questionBanner.currentQuestion != nextGate.question) {
      gameRef.questionBanner.setQuestion(nextGate.question);
    }

    if (currentQuestionIndex >= _questions.length && _activeGates.isEmpty) {
      gameRef.ref.read(gameStateProvider.notifier).winGame();
    }
  }

  void _spawnGate() {
    if (currentQuestionIndex >= _questions.length) return;

    final question = _questions[currentQuestionIndex];

    final answers = List<String>.from(question.options);
    final correctAnswer = answers[question.correctIndex];

    answers.shuffle(_random);

    final newCorrectIndex = answers.indexOf(correctAnswer);

    final gate = GateComponent(
      question: question.prompt,
      answers: answers,
      correctAnswerIndex: newCorrectIndex,
      worldX: 0,
      worldY: 0,
      worldZ: 120.0,
    );

    add(gate);
    _activeGates.add(gate);

    currentQuestionIndex++;
  }

  void _handleCollision(GateComponent gate, int playerLane) {
    bool isCorrect = false;

    int? hitIndex;
    for (int i = 0; i < gate.answers.length; i++) {
      // Find which index corresponds to playerLane
      // Note: PlayerController for 2 lanes uses -1 and 0? Or -1 and 1?
      if (gate.answers.length == 2) {
        if (i == 0 && playerLane == -1) hitIndex = 0;
        if (i == 1 && playerLane == 1) hitIndex = 1;

        if (i == 0 && playerLane == -1) hitIndex = 0;
        if (i == 1 && playerLane == 0) hitIndex = 1;
      } else {
        // 1 gate: lane 0. Player lane 0.
        // 3 gates: -1, 0, 1. Match.
        if (playerLane == (i - 1)) {
          // for 3 gates: 0->-1, 1->0, 2->1
          // So index 0 is at lane -1.
          if (playerLane == (i - 1)) hitIndex = i;
        } else if (gate.answers.length == 1 && playerLane == 0) {
          hitIndex = 0;
        }
      }
    }

    if (hitIndex != null) {
      isCorrect = hitIndex == gate.correctAnswerIndex;

      gate.showFeedback(playerLane, isCorrect);

      final gameStateFn = gameRef.ref.read(gameStateProvider.notifier);
      if (isCorrect) {
        // Correct!
        gameStateFn.incrementScore();
        gameStateFn.increaseSpeed();
        gameRef.player.triggerBoost();
      } else {
        // Wrong!
        gameStateFn.loseLife();
        gameStateFn.decreaseSpeed();
        gameRef.player.triggerStumble();
      }
    }
  }

  GateComponent? getNextGate() {
    GateComponent? nextGate;
    double closestZ = double.infinity;

    for (final gate in _activeGates) {
      if (!gate.hasCollided && gate.worldZ > gameRef.player.worldZ) {
        if (gate.worldZ < closestZ) {
          closestZ = gate.worldZ;
          nextGate = gate;
        }
      }
    }

    return nextGate;
  }
}
