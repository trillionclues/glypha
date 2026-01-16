import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glypha/core/widgets/layout/level_bottom_sheet.dart';
import 'package:glypha/features/home/data/model/level_data.dart';
import 'package:glypha/features/home/presentation/widgets/level_circle.dart';

class LevelNode extends StatelessWidget {
  final LevelData level;
  final AnimationController pulseController;

  const LevelNode({
    super.key,
    required this.level,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: level.isLocked
          ? () {
              HapticFeedback.heavyImpact();
              _showLockedFeedback(context);
            }
          : () {
              HapticFeedback.mediumImpact();
              _showLevelBottomSheet(context);
            },
      child: Column(
        children: [
          level.isCurrent
              ? AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    final scale = 1.0 +
                        (math.sin(pulseController.value * 2 * math.pi) * 0.08);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: LevelCircle(level: level),
                )
              : LevelCircle(level: level),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  level.title.isNotEmpty
                      ? level.title
                      : 'Level ${level.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: level.isLocked
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF4A5568),
                  ),
                ),
                if (level.isCompleted && level.stars > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: index < level.stars
                            ? const Color(0xFFFFD700)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Complete Level ${level.number - 1} to unlock'),
          ],
        ),
        backgroundColor: const Color(0xFF8B8B8B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLevelBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LevelBottomSheet(level: level),
    );
  }
}
