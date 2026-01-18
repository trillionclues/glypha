import 'package:flutter/material.dart';
import 'package:glypha/features/home/data/model/level_data.dart';
import 'package:glypha/features/home/presentation/widgets/landscape_layers.dart';
import 'package:glypha/features/home/presentation/widgets/level_node.dart';
import 'package:glypha/features/home/presentation/widgets/path_finder.dart';
import 'package:glypha/features/game/presentation/game_page.dart';

class MapView extends StatelessWidget {
  final ScrollController scrollController;
  final AnimationController pulseController;

  const MapView({
    super.key,
    required this.scrollController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final levels = [
      LevelData(1, 0.5, true, false, false, '📐',
          title: 'Intro', stars: 3, gameType: GameType.runner),
      LevelData(2, 0.3, true, false, false, '⚛️',
          title: 'Swipe Challenge', stars: 3, gameType: GameType.swipe),
      LevelData(3, 0.7, false, false, true, '🧪',
          title: 'Chemical Sort', gameType: GameType.stack),
      LevelData(4, 0.4, false, true, false, '🧬',
          title: 'Biology Swipe', gameType: GameType.swipe),
      LevelData(5, 0.6, false, true, false, '📐',
          title: 'Geometry Stack', gameType: GameType.stack),
      LevelData(6, 0.35, false, true, false, '⚛️',
          title: 'Physics', gameType: GameType.swipe),
      LevelData(7, 0.65, false, true, false, '🧪',
          title: 'Lab Work', gameType: GameType.runner),
      LevelData(8, 0.5, false, true, false, '🧬',
          title: 'Genetics', gameType: GameType.swipe),
    ];

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
  }
}
