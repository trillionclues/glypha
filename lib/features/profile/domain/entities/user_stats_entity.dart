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

  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  final DateTime? lastPlayedDate;

  const UserStats({
    required this.xp,
    required this.streak,
    required this.energy,
    required this.lastEnergyUpdate,
    this.lastPlayedDate,
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

  static DateTime? _timestampToDateTimeNullable(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    return null;
  }

  static dynamic _dateTimeToTimestampNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }

  static UserStats initial() => UserStats(
        xp: 0,
        streak: 0,
        energy: 1.0,
        lastEnergyUpdate: DateTime.now(),
        lastPlayedDate: null,
      );

  UserStats copyWith({
    int? xp,
    int? streak,
    double? energy,
    DateTime? lastEnergyUpdate,
    DateTime? lastPlayedDate,
  }) {
    return UserStats(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      energy: energy ?? this.energy,
      lastEnergyUpdate: lastEnergyUpdate ?? this.lastEnergyUpdate,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }

  /// Check user played yesterday (for streak continuation)
  bool get playedYesterday {
    if (lastPlayedDate == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _isSameDay(lastPlayedDate!, yesterday);
  }

  /// Check user already played today
  bool get playedToday {
    if (lastPlayedDate == null) return false;
    return _isSameDay(lastPlayedDate!, DateTime.now());
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
