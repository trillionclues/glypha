import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/features/profile/domain/entities/user_stats_entity.dart';
import 'package:glypha/features/profile/presentation/provider/user_stats_provider.dart';
import 'package:glypha/features/game/logic/game_state.dart';

class GameHeaderBar extends ConsumerWidget {
  const GameHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsNotifierProvider);
    final stats = statsAsync.value ?? UserStats.initial();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: stats.streak.toString(),
                  color: Colors.orange,
                ),
                _StatItem(
                  icon: Icons.star_rounded,
                  value: stats.xp.toString(),
                  color: Colors.amber,
                ),
                const _GoalDisplay(),
                const _LivesDisplay(),
                _EnergyBar(energy: stats.energy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
      ],
    );
  }
}

class _EnergyBar extends StatelessWidget {
  final double energy;

  const _EnergyBar({required this.energy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: energy,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivesDisplay extends ConsumerWidget {
  const _LivesDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final lives = gameState.lives;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < lives;
        return Icon(
          isActive ? Icons.favorite : Icons.favorite_border,
          color: isActive ? Colors.redAccent : Colors.white.withOpacity(0.4),
          size: 18,
        );
      }),
    );
  }
}

class _GoalDisplay extends ConsumerWidget {
  const _GoalDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final score = gameState.score;
    const goal = 8;
    final progress = (score / goal).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$score / $goal',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 40,
          height: 4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              score >= goal ? Colors.greenAccent : Colors.orangeAccent,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          'SCORE',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
