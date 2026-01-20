import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';
import 'package:glypha/features/profile/domain/entities/user_stats_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_stats_provider.g.dart';

@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  Stream<UserStats> build() {
    final authState = ref.watch(authNotifierProvider);
    if (authState is AuthAuthenticated) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(authState.user.id)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.data();
        if (data != null && data.containsKey('stats')) {
          return UserStats.fromJson(data['stats'] as Map<String, dynamic>);
        }
        return UserStats.initial();
      });
    }
    return Stream.value(UserStats.initial());
  }

  Future<void> addXp(int amount) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is AuthAuthenticated) {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(authState.user.id);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() ?? {};
        final statsMap = data['stats'] as Map<String, dynamic>?;
        final currentStats = statsMap != null
            ? UserStats.fromJson(statsMap)
            : UserStats.initial();

        final updatedStats = currentStats.copyWith(
          xp: currentStats.xp + amount,
        );

        transaction.update(docRef, {'stats': updatedStats.toJson()});
      });
    }
  }

  Future<void> consumeEnergy(double amount) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is AuthAuthenticated) {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(authState.user.id);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() ?? {};
        final statsMap = data['stats'] as Map<String, dynamic>?;
        final currentStats = statsMap != null
            ? UserStats.fromJson(statsMap)
            : UserStats.initial();

        final updatedStats = currentStats.copyWith(
          energy: (currentStats.energy - amount).clamp(0.0, 1.0),
          lastEnergyUpdate: DateTime.now(),
        );

        transaction.update(docRef, {'stats': updatedStats.toJson()});
      });
    }
  }
}
