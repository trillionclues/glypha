import 'dart:math';
import 'package:flame/components.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import '../logic/runner_game.dart';
import 'pseudo_3d_component.dart';
import 'gate_component.dart';

class WorldManager extends Component with HasGameRef<RunnerGame> {
  double spawnTimer = 0.0;
  final Random _random = Random();
  int currentQuestionIndex = 0;

  List<Question> _questions = [];
  bool _isInitialized = false;

  final List<GateComponent> _activeGates = [];

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

    if (!_isInitialized || gameRef.isGameOver) return;

    // Move all Pseudo3DComponents towards the camera
    _activeGates.removeWhere((gate) => gate.isRemoved);

    for (final child in children) {
      if (child is Pseudo3DComponent) {
        final speed = gameRef.currentSpeed;
        child.worldZ -= speed * dt;

        // Remove gates that are far behind the player
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

    if (currentQuestionIndex >= _questions.length && _activeGates.isEmpty) {
      gameRef.endGame();
    }
  }

  void _spawnGate() {
    if (currentQuestionIndex >= _questions.length) return;

    final question = _questions[currentQuestionIndex];

    final answers = List<String>.from(question.options);
    final correctAnswer = answers[question.correctIndex];

    answers.shuffle(_random);

    // Find new position of correct answer after shuffle
    final newCorrectIndex = answers.indexOf(correctAnswer);

    print(
        'Spawning gate for question ${currentQuestionIndex + 1}: ${question.prompt}');

    final gate = GateComponent(
      question: question.prompt,
      answers: answers,
      correctAnswerIndex: newCorrectIndex,
      worldX: 0,
      worldY: 0,
      worldZ: 120.0, // Spawn far away
    );

    add(gate);
    _activeGates.add(gate);

    currentQuestionIndex++;
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
