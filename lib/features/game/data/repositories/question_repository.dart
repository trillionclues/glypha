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

  // ============ UNIFIED COLLECTION ============

  Future<List<Question>> getUnifiedQuestionPool(String userId) async {
    final snapshot = await _firestore
        .collection('allQuestions')
        .where(Filter.or(
          Filter('ownerId', isEqualTo: 'SYSTEM'),
          Filter('ownerId', isEqualTo: userId),
        ))
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> saveQuestion(Question question) async {
    await _firestore
        .collection('allQuestions')
        .doc(question.id)
        .set(question.toJson());
  }

  Future<void> saveQuestionsBatch(List<Question> questions) async {
    final batch = _firestore.batch();

    for (final question in questions) {
      final ref = _firestore.collection('allQuestions').doc(question.id);
      batch.set(ref, question.toJson());
    }

    await batch.commit();
  }

  Future<void> deleteQuestion(String questionId) async {
    await _firestore.collection('allQuestions').doc(questionId).delete();
  }

  Future<List<Question>> getQuestionsByType(QuestionType type) async {
    final snapshot = await _firestore
        .collection('allQuestions')
        .where('type', isEqualTo: type.name)
        .limit(200)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<Question>> getQuestionsByTypeForUser(
      QuestionType type, String userId) async {
    final snapshot = await _firestore
        .collection('allQuestions')
        .where('type', isEqualTo: type.name)
        .where(Filter.or(
          Filter('ownerId', isEqualTo: 'SYSTEM'),
          Filter('ownerId', isEqualTo: userId),
        ))
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // ============ LEGACY / COMPATIBILITY ============

  Future<List<Question>> getQuestionsByTags(List<String> tags) async {
    final snapshot = await _firestore
        .collection('allQuestions')
        .where('tags', arrayContainsAny: tags)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}
