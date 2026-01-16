import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'question_repository.g.dart';

@riverpod
QuestionRepository questionRepository(QuestionRepositoryRef ref) {
  return QuestionRepository(FirebaseFirestore.instance);
}

class QuestionRepository {
  final FirebaseFirestore _firestore;

  QuestionRepository(this._firestore);

  // ============ SYSTEM QUESTIONS ============

  /// Get questions from a specific question bank (e.g., 'physics_101')
  Future<List<Question>> getQuestionsByBank(String bankId) async {
    final snapshot = await _firestore
        .collection('questionBanks')
        .doc(bankId)
        .collection('questions')
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Get questions by tags
  Future<List<Question>> getQuestionsByTags(List<String> tags) async {
    final snapshot = await _firestore
        .collectionGroup('questions')
        .where('tags', arrayContainsAny: tags)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // ============ USER-GENERATED QUESTIONS ============

  /// Get user's generated questions
  Future<List<Question>> getUserGeneratedQuestions(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('generatedQuestions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Save a user-generated question
  Future<void> saveUserQuestion(String userId, Question question) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('generatedQuestions')
        .doc(question.id)
        .set(question.toJson());
  }

  /// Save multiple user-generated questions (batch)
  Future<void> saveUserQuestionsBatch(
      String userId, List<Question> questions) async {
    final batch = _firestore.batch();

    for (final question in questions) {
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('generatedQuestions')
          .doc(question.id);
      batch.set(ref, question.toJson());
    }

    await batch.commit();
  }

  /// Delete a user-generated question
  Future<void> deleteUserQuestion(String userId, String questionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('generatedQuestions')
        .doc(questionId)
        .delete();
  }

  // ============ GAME SESSION ============

  /// Get random questions for a game session
  Future<List<Question>> getRandomQuestionsForGame({
    required String bankId,
    int count = 10,
    int? maxDifficulty,
  }) async {
    var query = _firestore
        .collection('questionBanks')
        .doc(bankId)
        .collection('questions')
        .limit(count * 3); // Fetch more for randomization

    if (maxDifficulty != null) {
      query = query.where('difficulty', isLessThanOrEqualTo: maxDifficulty);
    }

    final snapshot = await query.get();
    final questions = snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Shuffle and take requested count
    questions.shuffle();
    return questions.take(count).toList();
  }
}
