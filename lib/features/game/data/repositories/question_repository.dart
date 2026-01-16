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

  Future<List<Question>> getAllSystemQuestions() async {
    final snapshot = await _firestore.collection('questionBanks').get();
    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<Question>> getQuestionsByType(QuestionType type) async {
    final snapshot = await _firestore
        .collection('questionBanks')
        .where('type', isEqualTo: type.name)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// from a specific question bank (subcollection support)
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

  Future<List<Question>> getQuestionsByTags(List<String> tags) async {
    // Try root collection first
    final snapshot = await _firestore
        .collection('questionBanks')
        .where('tags', arrayContainsAny: tags)
        .limit(50)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }

    // Fallback to collectionGroup if using subcollections
    final fallbackSnapshot = await _firestore
        .collectionGroup('questions')
        .where('tags', arrayContainsAny: tags)
        .limit(50)
        .get();

    return fallbackSnapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // ============ USER-GENERATED QUESTIONS ============

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

  Future<void> saveUserQuestion(String userId, Question question) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('generatedQuestions')
        .doc(question.id)
        .set(question.toJson());
  }

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
