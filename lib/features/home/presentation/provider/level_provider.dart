import 'package:glypha/features/home/logic/level_generator.dart';
import 'package:glypha/features/game/data/repositories/question_repository.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'level_provider.g.dart';

@riverpod
Future<List<VirtualLevel>> levelList(Ref ref) async {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.user?.id ?? 'anonymous';

  final repository = ref.watch(questionRepositoryProvider);
  final pool = await repository.getUnifiedQuestionPool(userId);

  return LevelGenerator.generateLevels(pool);
}

@riverpod
Future<VirtualLevel?> virtualLevel(Ref ref, String levelId) async {
  final levels = await ref.watch(levelListProvider.future);
  try {
    return levels.firstWhere((l) => l.id == levelId);
  } catch (_) {
    return null;
  }
}
