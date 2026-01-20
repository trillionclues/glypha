import 'package:glypha/features/game/presentation/game_page.dart';

class LevelData {
  final String id;
  final int number;
  final double xPosition;
  final bool isCompleted;
  final bool isLocked;
  final bool isCurrent;
  final String emoji;
  final String title; // Topic name like 'Vocabulary', 'Grammar'
  final int stars; // 0-3 for completed levels
  final GameType gameType;

  LevelData(
    this.id,
    this.number,
    this.xPosition,
    this.isCompleted,
    this.isLocked,
    this.isCurrent,
    this.emoji, {
    this.title = '',
    this.stars = 0,
    this.gameType = GameType.runner,
  });
}
