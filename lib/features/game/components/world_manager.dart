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

  void setQuestions(List<Question> questions) {
    _questions = questions;
    _isInitialized = true;
    _spawnGate(); // Spawn first gate
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
    for (final child in children) {
      if (child is Pseudo3DComponent) {
        final speed = gameRef.currentSpeed;
        child.worldZ -= speed * dt;

        if (child.worldZ < Pseudo3DComponent.cameraZ - 5) {
          child.removeFromParent();
        }
      }
    }

    // Spawn new objects only if game is not over and we have questions left
    spawnTimer += dt;
    if (spawnTimer > 4.0 && currentQuestionIndex < _questions.length) {
      spawnTimer = 0;
      _spawnGate();
    }

    // Check if all questions are done
    if (currentQuestionIndex >= _questions.length && children.isEmpty) {
      gameRef.endGame();
    }
  }

  void _spawnGate() {
    if (currentQuestionIndex >= _questions.length) return;

    final question = _questions[currentQuestionIndex];
    currentQuestionIndex++;

    // Shuffle answer positions
    final answers = List<String>.from(question.options);
    final correctAnswer = answers[question.correctIndex];

    // Shuffle the answers
    answers.shuffle(_random);

    // Find new position of correct answer
    final newCorrectIndex = answers.indexOf(correctAnswer);

    final gate = GateComponent(
      question: question.prompt,
      answers: answers,
      correctAnswerIndex: newCorrectIndex,
      worldX: 0,
      worldY: 0,
      worldZ: 100.0,
    );

    add(gate);
  }
}
