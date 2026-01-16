import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameStateProvider =
    NotifierProvider<GameState, GameStateModel>(GameState.new);

class GameState extends Notifier<GameStateModel> {
  @override
  GameStateModel build() {
    return const GameStateModel(
      score: 0,
      lives: 3,
      currentSpeed: 10.0,
      isGameOver: false,
    );
  }

  void incrementScore() {
    state = state.copyWith(score: state.score + 1);
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
    state = const GameStateModel(
      score: 0,
      lives: 3,
      currentSpeed: 5.0,
      isGameOver: false,
    );
  }

  void setGameOver() {
    state = state.copyWith(isGameOver: true);
  }
}

class GameStateModel {
  final int score;
  final int lives;
  final double currentSpeed;
  final bool isGameOver;

  const GameStateModel({
    required this.score,
    required this.lives,
    required this.currentSpeed,
    required this.isGameOver,
  });

  GameStateModel copyWith({
    int? score,
    int? lives,
    double? currentSpeed,
    bool? isGameOver,
  }) {
    return GameStateModel(
      score: score ?? this.score,
      lives: lives ?? this.lives,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
