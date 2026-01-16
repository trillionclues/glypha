class LevelData {
  final int number;
  final double xPosition;
  final bool isCompleted;
  final bool isLocked;
  final bool isCurrent;
  final String emoji;
  final String title; // Topic name like 'Vocabulary', 'Grammar'
  final int stars; // 0-3 for completed levels

  LevelData(
    this.number,
    this.xPosition,
    this.isCompleted,
    this.isLocked,
    this.isCurrent,
    this.emoji, {
    this.title = '',
    this.stars = 0,
  });
}
