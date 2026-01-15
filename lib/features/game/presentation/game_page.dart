import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/runner_game.dart';
import '../logic/game_state.dart';

class GamePage extends ConsumerWidget {
  static const route = '/game';

  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Stack(
        children: [
          GameWidget<RunnerGame>.controlled(
            gameFactory: () => RunnerGame(ref),
            overlayBuilderMap: {
              'GameOver': (context, game) => Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black87,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'GAME OVER',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Reset game
                              ref.read(gameStateProvider.notifier).reset();
                              // We might need to reload the game widget or reset the game instance
                              // For now, simpler to just pop and push or have a reset method in game
                              // But since we are using Riverpod for state, we can just reset state.
                              // However, the game entities need to be reset too.
                              // Let's just pop for now.
                              Navigator.of(context).pop();
                            },
                            child: const Text('Exit'),
                          ),
                        ],
                      ),
                    ),
                  ),
            },
          ),

          // Score Overlay
          Positioned(
            top: 60,
            left: 20,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: ${gameState.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                  Text(
                    'Lives: ${gameState.lives}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (gameState.isGameOver)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(gameStateProvider.notifier).reset();
                        // Ideally we should tell the game to reset
                        // For now, let's just go back
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
