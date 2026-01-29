import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glypha/features/practice/domain/entities/scan_record_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';

part 'scan_record_provider.g.dart';

class ScanRecordRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  ScanRecordRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _scanCollection =>
      _firestore.collection('users').doc(_userId).collection('scans');

  Future<void> saveScan(ScanRecord scan) async {
    await _scanCollection.doc(scan.id).set(scan.toJson());
  }

  Future<void> updateScan(ScanRecord scan) async {
    await _scanCollection.doc(scan.id).update(scan.toJson());
  }

  Stream<List<ScanRecord>> watchScans() {
    return _scanCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScanRecord.fromJson(doc.data()))
            .toList());
  }

  Future<ScanRecord?> getScan(String id) async {
    final doc = await _scanCollection.doc(id).get();
    if (doc.exists) {
      return ScanRecord.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> deleteScan(String id) async {
    await _scanCollection.doc(id).delete();
  }

  Future<void> togglePublic(String id, bool isPublic) async {
    await _scanCollection.doc(id).update({'isPublic': isPublic});
  }
}

@riverpod
ScanRecordRepository scanRecordRepository(ScanRecordRepositoryRef ref) {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState is AuthAuthenticated ? authState.user.id : '';

  if (userId.isEmpty) {
    throw Exception('User must be authenticated to access scans');
  }

  return ScanRecordRepository(FirebaseFirestore.instance, userId);
}

@riverpod
Stream<List<ScanRecord>> userScans(UserScansRef ref) {
  final repository = ref.watch(scanRecordRepositoryProvider);
  return repository.watchScans();
}
