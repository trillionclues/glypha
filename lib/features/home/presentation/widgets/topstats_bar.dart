import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/features/profile/presentation/provider/user_stats_provider.dart';

class TopStatsBar extends ConsumerWidget {
  const TopStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(userStatsNotifierProvider);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: statsAsync.when(
                  data: (stats) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBadge(
                        emoji: '⚡',
                        value: '${(stats.energy * 100).toInt()}%',
                        label: 'Energy',
                      ),
                      _StatBadge(
                        emoji: '🔥',
                        value: stats.streak.toString(),
                        label: 'Streak',
                      ),
                      _StatBadge(
                        emoji: '✨',
                        value: _formatNumber(stats.xp),
                        label: 'XP',
                      ),
                      const _StatBadge(
                        emoji: '�',
                        value: '1.2k',
                        label: 'Gems',
                      ),
                    ],
                  ),
                  loading: () => const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBadge(emoji: '⚡', value: '--', label: 'Energy'),
                      _StatBadge(emoji: '�🔥', value: '--', label: 'Streak'),
                      _StatBadge(emoji: '✨', value: '--', label: 'XP'),
                      _StatBadge(emoji: '💎', value: '--', label: 'Gems'),
                    ],
                  ),
                  error: (_, __) => const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBadge(emoji: '⚡', value: '0', label: 'Energy'),
                      _StatBadge(emoji: '🔥', value: '0', label: 'Streak'),
                      _StatBadge(emoji: '✨', value: '0', label: 'XP'),
                      _StatBadge(emoji: '💎', value: '0', label: 'Gems'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _StatBadge extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatBadge({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
