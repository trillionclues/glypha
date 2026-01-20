import 'package:glypha/features/game/domain/entities/question_entity.dart';

class VirtualLevel {
  final String id;
  final String name;
  final List<Question> questions;
  final int difficulty;

  VirtualLevel({
    required this.id,
    required this.name,
    required this.questions,
    required this.difficulty,
  });

  bool get isCompleted =>
      false; // This will be checked against progression repo
}

class LevelGenerator {
  static const int questionsPerLevel = 10;

  /// Partition a pool of questions into dynamic levels sorted by difficulty.
  static List<VirtualLevel> generateLevels(List<Question> pool) {
    if (pool.isEmpty) return [];

    // Separate questions by type
    final binaryQuestions =
        pool.where((q) => q.type == QuestionType.binary).toList();
    final mcqQuestions = pool.where((q) => q.type == QuestionType.mcq).toList();
    // Assuming stack questions are identifiable or use MCQ with categories
    // For now, let's treat remaining MCQ as adaptable for Runner/Stack

    // Sort all by difficulty
    binaryQuestions.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    mcqQuestions.sort((a, b) => a.difficulty.compareTo(b.difficulty));

    final levels = <VirtualLevel>[];
    int levelCount = 0;

    // Cycle: Runner (MCQ), Swipe (Binary), Stack (MCQ/Category)
    // We try to fill levels according to this cycle

    while (binaryQuestions.isNotEmpty || mcqQuestions.isNotEmpty) {
      levelCount++;
      final gameTypeIndex =
          (levelCount - 1) % 3; // 0: Runner, 1: Swipe, 2: Stack

      List<Question> levelQuestions = [];

      if (gameTypeIndex == 1) {
        // Swipe (Needs Binary if possible)
        if (binaryQuestions.isNotEmpty) {
          final count = binaryQuestions.length >= questionsPerLevel
              ? questionsPerLevel
              : binaryQuestions.length;
          levelQuestions = binaryQuestions.sublist(0, count);
          binaryQuestions.removeRange(0, count);
        } else if (mcqQuestions.isNotEmpty) {
          // Fallback to MCQ if no binary left (Game will need to handle it or we skip)
          // Swipe game usually behaves badly with MCQ. Let's try to convert or skip.
          // For now, take MCQ but we should ideally implement standard Swipe = Binary.
          // We'll skip Swipe level if no Binary? No, just fill with what we have.
          final count = mcqQuestions.length >= questionsPerLevel
              ? questionsPerLevel
              : mcqQuestions.length;
          levelQuestions = mcqQuestions.sublist(0, count);
          mcqQuestions.removeRange(0, count);
        }
      } else {
        // Runner (0) or Stack (2) - Prefer MCQ
        if (mcqQuestions.isNotEmpty) {
          final count = mcqQuestions.length >= questionsPerLevel
              ? questionsPerLevel
              : mcqQuestions.length;
          levelQuestions = mcqQuestions.sublist(0, count);
          mcqQuestions.removeRange(0, count);
        } else if (binaryQuestions.isNotEmpty) {
          // Fallback
          final count = binaryQuestions.length >= questionsPerLevel
              ? questionsPerLevel
              : binaryQuestions.length;
          levelQuestions = binaryQuestions.sublist(0, count);
          binaryQuestions.removeRange(0, count);
        }
      }

      if (levelQuestions.isEmpty) break;

      // Determine average difficulty
      final avgDiff = (levelQuestions.fold(0, (sum, q) => sum + q.difficulty) /
              levelQuestions.length)
          .round();

      levels.add(VirtualLevel(
        id: 'level_$levelCount',
        name: 'Mission $levelCount',
        questions: levelQuestions,
        difficulty: avgDiff,
      ));
    }

    return levels;
  }
}
