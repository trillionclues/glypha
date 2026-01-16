import 'package:flutter/material.dart';
import 'package:glypha/features/home/data/model/level_data.dart';
import 'package:glypha/features/home/presentation/widgets/landscape_layers.dart';
import 'package:glypha/features/home/presentation/widgets/level_node.dart';
import 'package:glypha/features/home/presentation/widgets/path_finder.dart';

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
      LevelData(1, 0.5, true, false, false, '📐', title: 'Intro', stars: 3),
      LevelData(2, 0.3, true, false, false, '⚛️', title: 'Basics', stars: 3),
      LevelData(3, 0.7, false, false, true, '🧪', title: 'Chemistry'),
      LevelData(4, 0.4, false, true, false, '🧬', title: 'Biology'),
      LevelData(5, 0.6, false, true, false, '📐', title: 'Geometry'),
      LevelData(6, 0.35, false, true, false, '⚛️', title: 'Physics'),
      LevelData(7, 0.65, false, true, false, '🧪', title: 'Lab Work'),
      LevelData(8, 0.5, false, true, false, '🧬', title: 'Genetics'),
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
            // Light minimalist background matching mockup
            Container(
              height: totalHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5F0E8), // Light cream
                    Color(0xFFF8F4EE), // Warm off-white
                    Color(0xFFFAF8F5), // Very light beige
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
