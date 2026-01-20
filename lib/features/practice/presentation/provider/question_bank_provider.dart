import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glypha/features/practice/domain/entities/question_bank_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';

part 'question_bank_provider.g.dart';

class QuestionBankRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  QuestionBankRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _bankCollection =>
      _firestore.collection('users').doc(_userId).collection('generatedBanks');

  Future<void> saveBank(QuestionBank bank) async {
    await _bankCollection.doc(bank.id).set(bank.toJson());
  }

  Stream<List<QuestionBank>> watchBanks() {
    return _bankCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuestionBank.fromJson(doc.data()))
            .toList());
  }

  Future<void> deleteBank(String id) async {
    await _bankCollection.doc(id).delete();
  }
}

@riverpod
QuestionBankRepository questionBankRepository(QuestionBankRepositoryRef ref) {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState is AuthAuthenticated ? authState.user.id : '';

  if (userId.isEmpty) {
    throw Exception('User must be authenticated to access question banks');
  }

  return QuestionBankRepository(FirebaseFirestore.instance, userId);
}

@riverpod
Stream<List<QuestionBank>> userQuestionBanks(UserQuestionBanksRef ref) {
  final repository = ref.watch(questionBankRepositoryProvider);
  return repository.watchBanks();
}
