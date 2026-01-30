import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameStateProvider =
    NotifierProvider<GameState, GameStateModel>(GameState.new);

class GameState extends Notifier<GameStateModel> {
  @override
  GameStateModel build() {
    return const GameStateModel(
      score: 0,
      totalQuestions: 0,
      lives: 3,
      currentSpeed: 10.0,
      isGameOver: false,
      isVictory: false,
      stars: 0,
      questionIds: [],
      correctQuestionIds: [],
    );
  }

  void startGame(List<String> questionIds) {
    state = const GameStateModel(
      score: 0,
      lives: 3,
      currentSpeed: 10.0,
      isGameOver: false,
      isVictory: false,
      stars: 0,
    ).copyWith(
      totalQuestions: questionIds.length,
      questionIds: questionIds,
      correctQuestionIds: [],
    );
  }

  void incrementScore(String questionId) {
    state = state.copyWith(
      score: state.score + 1,
      correctQuestionIds: [...state.correctQuestionIds, questionId],
    );
  }

  void loseLife() {
    if (state.lives > 0) {
      state = state.copyWith(lives: state.lives - 1);
      if (state.lives == 0) {
        state = state.copyWith(isGameOver: true);
      }
    }
  }

  void increaseSpeed() {
    // +15% speed boost
    state = state.copyWith(currentSpeed: state.currentSpeed * 1.15);
  }

  void decreaseSpeed() {
    // -30% speed penalty
    state = state.copyWith(currentSpeed: state.currentSpeed * 0.70);
  }

  void restoreSpeed(double originalSpeed) {
    state = state.copyWith(currentSpeed: originalSpeed);
  }

  void reset() {
    // Reset to default
    state = const GameStateModel(
      score: 0,
      totalQuestions: 0,
      lives: 3,
      currentSpeed: 5.0,
      isGameOver: false,
      isVictory: false,
      stars: 0,
      questionIds: [],
      correctQuestionIds: [],
    );
  }

  void setGameOver() {
    state = state.copyWith(isGameOver: true, isVictory: false);
  }

  void winGame() {
    // Calculate stars
    int stars = 0;
    if (state.totalQuestions > 0) {
      final percentage = state.score / state.totalQuestions;
      if (percentage >= 0.99) {
        // ~100%
        stars = 3;
      } else if (percentage >= 0.9) {
        // 90%
        stars = 2;
      } else if (percentage >= 0.8) {
        // 80%
        stars = 1;
      }
    }

    state = state.copyWith(isGameOver: true, isVictory: true, stars: stars);
  }
}

class GameStateModel {
  final int score;
  final int totalQuestions;
  final int lives;
  final double currentSpeed;
  final bool isGameOver;
  final bool isVictory;
  final int stars;
  final List<String> questionIds;
  final List<String> correctQuestionIds;

  const GameStateModel({
    required this.score,
    this.totalQuestions = 0,
    required this.lives,
    required this.currentSpeed,
    required this.isGameOver,
    this.isVictory = false,
    this.stars = 0,
    this.questionIds = const [],
    this.correctQuestionIds = const [],
  });

  GameStateModel copyWith({
    int? score,
    int? totalQuestions,
    int? lives,
    double? currentSpeed,
    bool? isGameOver,
    bool? isVictory,
    int? stars,
    List<String>? questionIds,
    List<String>? correctQuestionIds,
  }) {
    return GameStateModel(
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lives: lives ?? this.lives,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      stars: stars ?? this.stars,
      questionIds: questionIds ?? this.questionIds,
      correctQuestionIds: correctQuestionIds ?? this.correctQuestionIds,
    );
  }
}
