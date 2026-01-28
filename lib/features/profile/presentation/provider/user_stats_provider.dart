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
        final stats = data != null && data.containsKey('stats')
            ? UserStats.fromJson(data['stats'] as Map<String, dynamic>)
            : UserStats.initial();

        return _calculateCurrentEnergy(stats);
      });
    }
    return Stream.value(UserStats.initial());
  }

  UserStats _calculateCurrentEnergy(UserStats stats) {
    if (stats.energy >= 1.0) {
      return stats;
    }

    final now = DateTime.now();
    final minutesElapsed = now.difference(stats.lastEnergyUpdate).inMinutes;

    if (minutesElapsed <= 0) {
      return stats;
    }

    // Calculate recharge: 1% per minute
    final recharge = minutesElapsed * 0.01;
    final newEnergy = (stats.energy + recharge).clamp(0.0, 1.0);

    return stats.copyWith(
      energy: newEnergy,
    );
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

  // Update streak based on consecutive daily play.
  // Called when user completes a level.
  Future<void> updateStreak() async {
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

        final now = DateTime.now();
        int newStreak = currentStats.streak;

        if (currentStats.playedToday) {
          return;
        }

        if (currentStats.playedYesterday) {
          newStreak = currentStats.streak + 1;
        } else {
          newStreak = 1;
        }

        final updatedStats = currentStats.copyWith(
          streak: newStreak,
          lastPlayedDate: now,
        );

        transaction.update(docRef, {'stats': updatedStats.toJson()});
      });
    }
  }

  // Recharges energy based on time elapsed since last update.
  // Energy regenerates at 1% per minute (full recharge in ~100 minutes).
  Future<void> rechargeEnergy() async {
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

        final now = DateTime.now();
        final minutesElapsed =
            now.difference(currentStats.lastEnergyUpdate).inMinutes;

        if (minutesElapsed <= 0 || currentStats.energy >= 1.0) {
          return;
        }

        final recharge = minutesElapsed * 0.01;
        final newEnergy = (currentStats.energy + recharge).clamp(0.0, 1.0);

        final updatedStats = currentStats.copyWith(
          energy: newEnergy,
          lastEnergyUpdate: now,
        );

        transaction.update(docRef, {'stats': updatedStats.toJson()});
      });
    }
  }

// Consume energy when starting a level
// ONLY method that writes energy to Firebase
  Future<void> consumeEnergy(double amount) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      throw Exception('User not authenticated');
    }

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(authState.user.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};
      final statsMap = data['stats'] as Map<String, dynamic>?;
      final currentStats =
          statsMap != null ? UserStats.fromJson(statsMap) : UserStats.initial();

      final statsWithRecharge = _calculateCurrentEnergy(currentStats);

      if (statsWithRecharge.energy < amount) {
        throw Exception(
            'Not enough energy. Current: ${statsWithRecharge.energy}, Required: $amount');
      }

      final updatedStats = currentStats.copyWith(
        energy: (statsWithRecharge.energy - amount).clamp(0.0, 1.0),
        lastEnergyUpdate: DateTime.now(),
      );

      transaction.update(docRef, {'stats': updatedStats.toJson()});
    });
  }

  // Optional: Force sync energy to Firebase without consuming
  // Useful to persist the recharged energy occasionally
  Future<void> syncEnergyToFirebase() async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) return;

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(authState.user.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};
      final statsMap = data['stats'] as Map<String, dynamic>?;
      final currentStats =
          statsMap != null ? UserStats.fromJson(statsMap) : UserStats.initial();

      final statsWithRecharge = _calculateCurrentEnergy(currentStats);

      if (statsWithRecharge.energy == currentStats.energy) {
        return;
      }

      final updatedStats = statsWithRecharge.copyWith(
        lastEnergyUpdate: DateTime.now(),
      );

      transaction.update(docRef, {'stats': updatedStats.toJson()});
    });
  }
}
