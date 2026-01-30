import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glypha/features/home/domain/entities/level_progression_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progression_repository.g.dart';

@riverpod
ProgressionRepository progressionRepository(ProgressionRepositoryRef ref) {
  return ProgressionRepository(FirebaseFirestore.instance);
}

class ProgressionRepository {
  final FirebaseFirestore _firestore;

  ProgressionRepository(this._firestore);

  CollectionReference<LevelProgression> _getProgressionRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progression')
        .withConverter<LevelProgression>(
          fromFirestore: (snapshot, _) =>
              LevelProgression.fromJson(snapshot.data()!),
          toFirestore: (prog, _) => prog.toJson(),
        );
  }

  Future<List<LevelProgression>> getUserProgression(String userId) async {
    final snapshot = await _getProgressionRef(userId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Stream progression for real-time updates
  Stream<List<LevelProgression>> watchUserProgression(String userId) {
    return _getProgressionRef(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> updateProgression(
      String userId, LevelProgression progression) async {
    await _getProgressionRef(userId)
        .doc(progression.levelId)
        .set(progression, SetOptions(merge: true));
  }

  // Mark level as completed with score and stars
  Future<void> completeLevel({
    required String userId,
    required String levelId,
    required int score,
    required int stars,
    List<String>? questionIds,
  }) async {
    final ref = _getProgressionRef(userId).doc(levelId);
    final doc = await ref.get();

    if (doc.exists) {
      final existing = doc.data()!;
      await ref.update({
        'isCompleted': true,
        'bestScore': score > existing.bestScore ? score : existing.bestScore,
        'stars': stars > existing.stars ? stars : existing.stars,
        'attempts': FieldValue.increment(1),
        'lastPlayed': FieldValue.serverTimestamp(),
        if (questionIds != null) 'questionIds': questionIds,
      });
    } else {
      await ref.set(LevelProgression(
        levelId: levelId,
        isCompleted: true,
        bestScore: score,
        stars: stars,
        attempts: 1,
        lastPlayed: DateTime.now(),
        questionIds: questionIds ?? [],
      ));
    }
  }
}
