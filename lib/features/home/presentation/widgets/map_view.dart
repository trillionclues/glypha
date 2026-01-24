import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/features/home/data/model/level_data.dart';
import 'package:glypha/features/home/presentation/widgets/landscape_layers.dart';
import 'package:glypha/features/home/presentation/widgets/level_node.dart';
import 'package:glypha/features/home/presentation/widgets/path_finder.dart';
import 'package:glypha/features/game/presentation/game_page.dart';
import 'package:glypha/features/home/presentation/provider/progression_provider.dart';
import 'package:glypha/features/home/presentation/provider/level_provider.dart';

class MapView extends ConsumerWidget {
  final ScrollController scrollController;
  final AnimationController pulseController;

  const MapView({
    super.key,
    required this.scrollController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final levelListAsync = ref.watch(levelListProvider);
    final progressionMap = ref.watch(progressionMapProvider);

    return levelListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (dynamicLevels) {
        if (dynamicLevels.isEmpty) {
          return const Center(
            child: Text('No questions found. Add some in the Questions tab!'),
          );
        }

        final levels = <LevelData>[];
        bool foundCurrent = false;

        for (int i = 0; i < dynamicLevels.length; i++) {
          final virtualLevel = dynamicLevels[i];
          final id = virtualLevel.id;
          final prog = progressionMap[id];

          final isCompleted = prog?.isCompleted ?? false;
          final previousCompleted = i == 0 ||
              (progressionMap[dynamicLevels[i - 1].id]?.isCompleted ?? false);

          bool isLocked = !previousCompleted;
          bool isCurrent = false;

          if (!isCompleted && previousCompleted && !foundCurrent) {
            isCurrent = true;
            foundCurrent = true;
          }

          // Zig-zag pattern for x position
          double xPos = 0.5;
          if (i % 2 == 0) {
            xPos = 0.3 + (i % 4 == 0 ? 0.0 : 0.4);
          } else {
            xPos = 0.7 - (i % 3 == 0 ? 0.2 : 0.0);
          }

          // Assign game type based on index
          final types = [GameType.runner, GameType.swipe, GameType.stack];
          final gameType = types[i % types.length];

          // Choose emoji based on difficulty or index
          final emojis = ['📐', '⚛️', '🧪', '🧬', '🔭', '🔬', '🧠'];
          final emoji = emojis[i % emojis.length];

          levels.add(LevelData(
            id,
            i + 1,
            xPos,
            isCompleted,
            isLocked,
            isCurrent,
            emoji,
            title: virtualLevel.name,
            stars: prog?.stars ?? 0,
            gameType: gameType,
          ));
        }

        final totalHeight = 180.0 * levels.length + 400.0;

        return SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: screenWidth,
            height: totalHeight,
            child: Stack(
              children: [
                Container(
                  height: totalHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF5F0E8),
                        Color(0xFFF8F4EE),
                        Color(0xFFFAF8F5),
                      ],
                    ),
                  ),
                ),
                LandscapeLayers(height: totalHeight),
                CustomPaint(
                  size: Size(screenWidth, totalHeight),
                  painter: DashedRoadPathPainter(levels, screenWidth),
                ),
                ...levels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final level = entry.value;
                  // Levels rendered bottom to top
                  final yPosition = (levels.length - index) * 180.0 + 50;

                  return Positioned(
                    left: screenWidth * level.xPosition - 35,
                    top: yPosition,
                    child: LevelNode(
                      level: level,
                      pulseController: pulseController,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
