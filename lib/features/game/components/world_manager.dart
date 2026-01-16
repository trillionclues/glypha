import 'dart:math';
import 'package:flame/components.dart';
import '../logic/runner_game.dart';
import 'pseudo_3d_component.dart';
import 'gate_component.dart';

class WorldManager extends Component with HasGameRef<RunnerGame> {
  double spawnTimer = 0.0;
  final Random _random = Random();
  int currentQuestionIndex = 0;

  // Sample questions pool - answers are in fixed order for each question
  final List<Map<String, dynamic>> _questionPool = [
    {
      'question': 'What is 2 + 2?',
      'answers': ['3', '4', '5'],
      'correct': 1, // Index of correct answer
    },
    {
      'question': 'What is the capital of France?',
      'answers': ['London', 'Paris', 'Berlin'],
      'correct': 1,
    },
    {
      'question': 'How many continents are there?',
      'answers': ['5', '6', '7'],
      'correct': 2,
    },
    {
      'question': 'What color is the sky?',
      'answers': ['Green', 'Blue', 'Red'],
      'correct': 1,
    },
    {
      'question': 'What is 10 × 5?',
      'answers': ['40', '50', '60'],
      'correct': 1,
    },
  ];

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Spawn first gate immediately
    _spawnGate();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Stop all movement if game is over
    if (gameRef.isGameOver) return;

    // Move all Pseudo3DComponents towards the camera
    for (final child in children) {
      if (child is Pseudo3DComponent) {
        // Move object towards camera (decrease Z)
        final speed = gameRef.currentSpeed;
        child.worldZ -= speed * dt;

        // Remove if behind camera
        if (child.worldZ < Pseudo3DComponent.cameraZ - 5) {
          child.removeFromParent();
        }
      }
    }

    // Spawn new objects only if game is not over and we have questions left
    spawnTimer += dt;
    if (spawnTimer > 4.0 &&
        !gameRef.isGameOver &&
        currentQuestionIndex < _questionPool.length) {
      spawnTimer = 0;
      _spawnGate();
    }

    // Check if all questions are done
    if (currentQuestionIndex >= _questionPool.length && children.isEmpty) {
      // All questions answered and no gates left
      gameRef.endGame();
    }
  }

  void _spawnGate() {
    if (currentQuestionIndex >= _questionPool.length) return;

    final questionData = _questionPool[currentQuestionIndex];
    currentQuestionIndex++;

    // Shuffle answer positions
    final answers = List<String>.from(questionData['answers'] as List);
    final correctAnswer = answers[questionData['correct'] as int];

    // Shuffle the answers
    answers.shuffle(_random);

    // Find new position of correct answer
    final newCorrectIndex = answers.indexOf(correctAnswer);

    final gate = GateComponent(
      question: questionData['question'] as String,
      answers: answers,
      correctAnswerIndex: newCorrectIndex,
      worldX: 0,
      worldY: 0,
      worldZ: 100.0,
    );

    add(gate);
    // Don't update question here - it will update on collision
  }
}
