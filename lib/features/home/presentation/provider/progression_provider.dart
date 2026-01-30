import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';
import 'package:glypha/features/home/data/repositories/progression_repository.dart';
import 'package:glypha/features/home/domain/entities/level_progression_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progression_provider.g.dart';

@riverpod
Stream<List<LevelProgression>> progressionStream(ProgressionStreamRef ref) {
  final authState = ref.watch(authNotifierProvider);

  if (authState is AuthAuthenticated) {
    return ref
        .watch(progressionRepositoryProvider)
        .watchUserProgression(authState.user.id);
  }

  return Stream.value([]);
}

@riverpod
Map<String, LevelProgression> progressionMap(ProgressionMapRef ref) {
  final progression = ref.watch(progressionStreamProvider).value ?? [];
  return {for (var p in progression) p.levelId: p};
}

@riverpod
class ProgressionNotifier extends _$ProgressionNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> completeLevel({
    required String levelId,
    required int score,
    required int stars,
    List<String>? questionIds,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is AuthAuthenticated) {
      await ref.read(progressionRepositoryProvider).completeLevel(
            userId: authState.user.id,
            levelId: levelId,
            score: score,
            stars: stars,
            questionIds: questionIds,
          );
    }
  }
}
