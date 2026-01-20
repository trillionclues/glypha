import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_stats_entity.g.dart';

@JsonSerializable()
class UserStats {
  final int xp;
  final int streak;
  final double energy; // 0.0 to 1.0

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime lastEnergyUpdate;

  const UserStats({
    required this.xp,
    required this.streak,
    required this.energy,
    required this.lastEnergyUpdate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    return DateTime.now();
  }

  static dynamic _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  static UserStats initial() => UserStats(
        xp: 0,
        streak: 0,
        energy: 1.0,
        lastEnergyUpdate: DateTime.now(),
      );

  UserStats copyWith({
    int? xp,
    int? streak,
    double? energy,
    DateTime? lastEnergyUpdate,
  }) {
    return UserStats(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      energy: energy ?? this.energy,
      lastEnergyUpdate: lastEnergyUpdate ?? this.lastEnergyUpdate,
    );
  }
}
