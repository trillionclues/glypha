import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'package:glypha/features/game/domain/entities/game_type.dart';

class VirtualLevel {
  final String id;
  final String name;
  final List<Question> questions;
  final int difficulty;
  final GameType gameType;
  final int questionCount;

  VirtualLevel({
    required this.id,
    required this.name,
    required this.questions,
    required this.difficulty,
    this.gameType = GameType.runner, // Default
  }) : questionCount = questions.length;

  bool get isCompleted => false;
}

class LevelGenerator {
  static const int minQuestions = 5;
  static const int maxQuestions = 10;

  static List<VirtualLevel> generateLevels(List<Question> pool) {
    if (pool.isEmpty) return [];

    // 1. Organize questions by compatible GameType with stricter validation
    final Map<GameType, List<Question>> pools = {
      GameType.runner: [],
      GameType.swipe: [],
      GameType.stack: [],
      GameType.match: [],
    };

    for (final q in pool) {
      // Explicit compatibility
      if (q.compatibleModes.isNotEmpty) {
        for (final mode in q.compatibleModes) {
          if (_isValidForMode(q, mode)) {
            pools[mode]?.add(q);
          }
        }
      } else {
        _assignToInferredModes(q, pools);
      }
    }

    // Sort by difficulty
    for (final key in pools.keys) {
      pools[key]?.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    }

    final levels = <VirtualLevel>[];
    int levelCount = 0;
    final Set<String> usedQuestionIds = {};

    // 2. Generate levels - Alternate between available modes (Runner <-> Swipe)
    final activeModes = [
      GameType.runner,
      GameType.swipe,
      // GameType.stack,
      // GameType.match,
    ];

    bool generatedAny;
    do {
      generatedAny = false;
      for (final gameType in activeModes) {
        final modePool = pools[gameType]!;

        // Get valid available questions
        final available =
            modePool.where((q) => !usedQuestionIds.contains(q.id)).toList();

        if (available.length >= minQuestions) {
          // Runner, Swipe, Runner, Swipe.
          // So we generate ONE level per mode per pass.
          // Else we keep generating levels for this mode as long as we can
          final countToTake = available.length >= maxQuestions
              ? maxQuestions
              : available.length;
          final levelQuestions = available.sublist(0, countToTake);

          for (final q in levelQuestions) {
            usedQuestionIds.add(q.id);
          }

          levelCount++;
          final avgDiff =
              (levelQuestions.fold(0, (sum, q) => sum + q.difficulty) /
                      levelQuestions.length)
                  .round();

          levels.add(VirtualLevel(
            id: 'level_$levelCount',
            name: 'Mission $levelCount',
            questions: levelQuestions,
            difficulty: avgDiff,
            gameType: gameType,
          ));

          generatedAny = true;
        }
      }
    } while (generatedAny);

    // Fallback: If any other modes (like Match or Stack if not in activeModes) have questions, handle them?
    // User specifically asked to "continue with the remaining mode", which is handled by the loop above
    // (if Runner runs out, Swipe continues in next iterations).
    // So this logic covers both alternation and exhaustion.

    return levels;
  }

  static bool _isValidForMode(Question q, GameType mode) {
    switch (mode) {
      case GameType.runner:
        // Runner gates needs 2-3 options
        return q.options.length >= 2 && q.options.length <= 3;
      case GameType.swipe:
        // Swipe needs exactly 2 options (Binary or 2-option MCQ)
        return q.options.length == 2;
      case GameType.stack:
        // Stack buckets needs 2-3 options
        return q.options.length >= 2 && q.options.length <= 3;
      case GameType.match:
        return q.type == QuestionType.matchPair;
    }
  }

  static void _assignToInferredModes(
      Question q, Map<GameType, List<Question>> pools) {
    if (q.type == QuestionType.matchPair) {
      pools[GameType.match]?.add(q);
      return;
    }

    // Check option counts for other modes
    if (q.options.length == 2) {
      pools[GameType.swipe]?.add(q);
      pools[GameType.runner]?.add(q);
      pools[GameType.stack]?.add(q);
    } else if (q.options.length == 3) {
      pools[GameType.runner]?.add(q);
      pools[GameType.stack]?.add(q);
    } else if (q.options.length == 4) {
      pools[GameType.stack]?.add(q); // Stack supported 4 cols
    }
  }
}
