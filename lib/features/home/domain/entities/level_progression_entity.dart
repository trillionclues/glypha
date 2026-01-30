import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'level_progression_entity.g.dart';

@JsonSerializable()
class LevelProgression {
  final String levelId;
  final bool isCompleted;
  final int bestScore;
  final int stars;
  final int attempts;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime lastPlayed;

  final List<String> questionIds;

  LevelProgression({
    required this.levelId,
    required this.isCompleted,
    required this.bestScore,
    required this.stars,
    required this.attempts,
    required this.lastPlayed,
    this.questionIds = const [],
  });

  factory LevelProgression.fromJson(Map<String, dynamic> json) =>
      _$LevelProgressionFromJson(json);

  Map<String, dynamic> toJson() => _$LevelProgressionToJson(this);

  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    return DateTime.now();
  }

  static dynamic _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}
