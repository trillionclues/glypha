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

    // Move all Pseudo3DComponents towards the camera
    _activeGates.removeWhere((gate) => gate.isRemoved);

    // Check for collisions
    final player = gameRef.player;
    final playerZ = player.worldZ;

    for (final child in children) {
      if (child is Pseudo3DComponent) {
        final speed = gameRef.currentSpeed;
        child.worldZ -= speed * dt;

        // Collision Check
        if (child is GateComponent && !child.hasCollided) {
          // Gate is "thick" (Z-depth assumed small), check if it passed player
          // Player is at -5.0. Gate comes from +Z.
          // If gate crosses -5.0, check lane.
          if (child.worldZ <= playerZ + 0.5 && child.worldZ >= playerZ - 0.5) {
            _handleCollision(child, player.currentLane);
          }
        }

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

    // Strictly update banner to the closest valid gate
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

    // Find new position of correct answer after shuffle
    final newCorrectIndex = answers.indexOf(correctAnswer);

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

    // Banner update removed here - handled in update() via getNextGate()

    currentQuestionIndex++;
  }

  void _handleCollision(GateComponent gate, int playerLane) {
    // Map player lane to answer index
    // Gate has a helper mapping, let's use a simpler logic or use gate's internal check
    // We'll trust gate.showFeedback to determine if hit was correct based on visual mapping
    // But we need the logic here.

    // Determining if correct:
    bool isCorrect = false;

    // Logic matched from GateComponent's visual mapping:
    // 1 gate: Lane 0
    // 2 gates: Lane -1 (Left), Lane 1 (Same as 0 visually? No, mapped to Left/Right)
    // Wait, PlayerController uses -1, 0, 1.
    // GateComponent mapping:
    // 2 Gates: index 0 (Left, -1), index 1 (Right, 1) -- wait, 1 is mapped to Right (lane 0 in 2-lane mode?)
    // Let's re-verify GateComponent mapping.
    // In 2-gate mode: laneX = (i==0)?-0.8:0.8. _laneMapping: [ -1, 1 ].
    // So if playerLane == -1 (Left), it hits index 0. If playerLane == 1 (Right), it hits index 1.
    // If playerLane is 0 (Center), it hits nothing? (Gap).

    // 3 Gates: -1, 0, 1.

    int? hitIndex;
    for (int i = 0; i < gate.answers.length; i++) {
      // Find which index corresponds to playerLane
      if (gate.answers.length == 2) {
        if (i == 0 && playerLane == -1) hitIndex = 0;
        if (i == 1 && playerLane == 1) hitIndex = 1;
        // Note: PlayerController for 2 lanes uses -1 and 0? Or -1 and 1?
        // Let's check PlayerController._maxLane for 2 lanes.
        // It set _minLane = -1, _maxLane = 0.
        // Wait. PlayerController: "case 2: _minLane = -1; _maxLane = 0;"
        // And _getLanePosition: "lane == -1 ? -0.8 : 0.8".
        // So Lane 0 is Right. Lane -1 is Left.
        // GateComponent 2-gate mapping: "laneX = (i==0)?-0.8:0.8". LaneMapping: [-1, 1].
        // MISMATCH! Gate expects lane 1 for Right, Player uses lane 0 for Right.
        // FIX: We should fix Logic here.

        if (i == 0 && playerLane == -1) hitIndex = 0; // Left
        if (i == 1 && playerLane == 0)
          hitIndex = 1; // Right (Lane 0 in player logic)
      } else {
        // 1 or 3 gates
        // 1 gate: lane 0. Player lane 0.
        // 3 gates: -1, 0, 1. Match.
        if (playerLane == (i - 1)) {
          // for 3 gates: 0->-1, 1->0, 2->1
          // Wait, logic in GateComponent: "_laneMapping.add(i - 1)" for 3 gates.
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

      // Update Question Banner for next question immediately?
      // Or Wait? Usually next gate spawns with next question.
      // Question banner shows CURRENT active question.
      // We should update it when the NEXT gate spawns or becomes active.
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
