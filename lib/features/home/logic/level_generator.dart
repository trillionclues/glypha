import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'package:glypha/features/game/domain/entities/game_type.dart';

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

  bool get isCompleted => false; // This is checked against progression repo
}

class LevelGenerator {
  static const int questionsPerLevel = 10;

  /// Partition a pool of questions into dynamic levels sorted by difficulty.
  /// Separate questions by type
  /// Assuming stack questions are identifiable or use MCQ with categories
  /// For now, let's treat remaining MCQ as adaptable for Runner/Stack

  static List<VirtualLevel> generateLevels(List<Question> pool) {
    if (pool.isEmpty) return [];

    // 1. Organize questions by compatible GameType
    // A question can belong to multiple pools if it's compatible with multiple modes
    final Map<GameType, List<Question>> pools = {
      GameType.runner: [],
      GameType.swipe: [],
      GameType.stack: [],
      GameType.match: [],
    };

    for (final q in pool) {
      // If compatibleModes is explicit, use it
      if (q.compatibleModes.isNotEmpty) {
        for (final mode in q.compatibleModes) {
          pools[mode]?.add(q);
        }
      } else {
        // Fallback inference (Strict Mode)
        switch (q.type) {
          case QuestionType.binary:
            pools[GameType.swipe]?.add(q);
            pools[GameType.runner]?.add(q); // Runner works with binary too
            break;
          case QuestionType.mcq:
            // Stack usually needs categorization (prompt has "Category:")
            // We can't easily infer Stack without explicit data, but we can assume generic MCQ is for Runner
            pools[GameType.runner]?.add(q);
            break;
          case QuestionType.matchPair:
            pools[GameType.match]?.add(q);
            break;
          default:
            break;
        }
      }
    }

    // Sort all pools by difficulty
    for (final key in pools.keys) {
      pools[key]?.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    }

    final levels = <VirtualLevel>[];
    int levelCount = 0;

    // Cycle order: Runner -> Swipe -> Stack -> Match
    final cycle = [
      GameType.runner,
      GameType.swipe,
      GameType.stack,
      GameType.match
    ];

    // Track used question IDs to prevent re-using the same question in multiple levels
    final Set<String> usedQuestionIds = {};

    bool canCreateLevel = true;
    int cycleIndex = 0;

    while (canCreateLevel) {
      bool levelAddedInThisCycle = false;

      // Try to find a mode that has enough questions
      // We start from current cycleIndex, but if that fails, we check next modes
      // If we go fully around the cycle and add nothing, we stop.

      int attempts = 0;
      while (attempts < cycle.length) {
        final gameType = cycle[cycleIndex];
        final poolForMode = pools[gameType]!;

        // Filter out already used questions from this pool on the fly
        // (Efficiency note: we could remove from lists, but Set lookup is O(1))
        final available =
            poolForMode.where((q) => !usedQuestionIds.contains(q.id)).toList();

        if (available.length >= questionsPerLevel) {
          // Create Level
          final levelQuestions = available.sublist(0, questionsPerLevel);

          // Mark as used
          for (final q in levelQuestions) {
            usedQuestionIds.add(q.id);
          }

          levelCount++;
          // Calculate average difficulty
          final avgDiff =
              (levelQuestions.fold(0, (sum, q) => sum + q.difficulty) /
                      levelQuestions.length)
                  .round();

          levels.add(VirtualLevel(
            id: 'level_$levelCount',
            name:
                'Mission $levelCount', // Could customize name based on GameType? e.g. "Speed Run", "Swipe Master"
            questions: levelQuestions,
            difficulty: avgDiff,
          ));

          levelAddedInThisCycle = true;
          cycleIndex = (cycleIndex + 1) % cycle.length;
          break; // Created one level, go to next iteration of outer loop
        }

        // Try next mode
        cycleIndex = (cycleIndex + 1) % cycle.length;
        attempts++;
      }

      if (!levelAddedInThisCycle) {
        canCreateLevel = false;
      }
    }

    return levels;
  }
}
