import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/features/game/logic/swipe_master_game.dart';
import 'package:glypha/features/game/logic/stack_attack_game.dart';
import 'package:glypha/features/game/presentation/widgets/game_header_bar.dart';
import 'package:glypha/features/home/presentation/provider/progression_provider.dart';
import 'package:glypha/features/profile/presentation/provider/user_stats_provider.dart';
import '../logic/runner_game.dart';
import '../logic/game_state.dart';

enum GameType {
  runner,
  swipe,
  stack,
  match,
}

class GamePage extends ConsumerStatefulWidget {
  static const route = '/game';
  final GameType gameType;
  final String? levelId;

  const GamePage({
    super.key,
    this.gameType = GameType.runner,
    this.levelId,
  });

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    // Auto-hide instructions after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showInstructions = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Game?'),
            content: const Text('Your progress for this level will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        if (shouldPop ?? false) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildGame(ref),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: GameHeaderBar(),
              ),
            ),
            if (_showInstructions)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showInstructions = false;
                    });
                  },
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: widget.gameType == GameType.runner
                            ? _buildRunnerInstructions()
                            : _buildSwipeInstructions(),
                      ),
                    ),
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
                      Text(
                        gameState.isVictory ? 'VICTORY!' : 'GAME OVER',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Score: ${gameState.score}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      if (gameState.isVictory) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (index) => Icon(
                              Icons.star_rounded,
                              size: 40,
                              color: index < _calculateStars(gameState.score)
                                  ? Colors.amber
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (gameState.isVictory && widget.levelId != null) {
                            await ref
                                .read(progressionNotifierProvider.notifier)
                                .completeLevel(
                                  levelId: widget.levelId!,
                                  score: gameState.score,
                                  stars: _calculateStars(gameState.score),
                                );

                            // Award XP: 50 base + 10 per star
                            final xpGain =
                                50 + (_calculateStars(gameState.score) * 10);
                            await ref
                                .read(userStatsNotifierProvider.notifier)
                                .addXp(xpGain);
                          }
                          ref.read(gameStateProvider.notifier).reset();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunnerInstructions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.swipe,
          size: 64,
          color: Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        const Text(
          'How to Play',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSwipeInstruction(
              Icons.arrow_back,
              'Swipe Left',
              Colors.blue,
            ),
            _buildSwipeInstruction(
              Icons.arrow_forward,
              'Swipe Right',
              Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Swipe anywhere on the screen to move between answer gates',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showInstructions = false;
            });
          },
          child: const Text(
            'Got it!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeInstructions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.touch_app,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Swipe Cards',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSwipeInstruction(
              Icons.arrow_back,
              'FALSE',
              Colors.red,
            ),
            _buildSwipeInstruction(
              Icons.arrow_forward,
              'TRUE',
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Read the question and swipe the card\nleft for FALSE or right for TRUE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showInstructions = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Start Playing!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeInstruction(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGame(WidgetRef ref) {
    switch (widget.gameType) {
      case GameType.runner:
        return GameWidget<RunnerGame>.controlled(
          gameFactory: () => RunnerGame(ref, levelId: widget.levelId),
        );
      case GameType.swipe:
        return GameWidget<SwipeMasterGame>.controlled(
          gameFactory: () => SwipeMasterGame(ref, levelId: widget.levelId),
        );
      case GameType.stack:
        return GameWidget<StackAttackGame>.controlled(
          gameFactory: () => StackAttackGame(ref, levelId: widget.levelId),
        );
      default:
        return const Center(child: Text('Game mode not implemented'));
    }
  }

  int _calculateStars(int score) {
    if (score >= 15) return 3;
    if (score >= 10) return 2;
    if (score >= 5) return 1;
    return 0;
  }
}
