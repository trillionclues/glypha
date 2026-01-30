// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_progression_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelProgression _$LevelProgressionFromJson(Map<String, dynamic> json) =>
    LevelProgression(
      levelId: json['levelId'] as String,
      isCompleted: json['isCompleted'] as bool,
      bestScore: (json['bestScore'] as num).toInt(),
      stars: (json['stars'] as num).toInt(),
      attempts: (json['attempts'] as num).toInt(),
      lastPlayed: LevelProgression._timestampToDateTime(json['lastPlayed']),
      questionIds: (json['questionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LevelProgressionToJson(LevelProgression instance) =>
    <String, dynamic>{
      'levelId': instance.levelId,
      'isCompleted': instance.isCompleted,
      'bestScore': instance.bestScore,
      'stars': instance.stars,
      'attempts': instance.attempts,
      'lastPlayed': LevelProgression._dateTimeToTimestamp(instance.lastPlayed),
      'questionIds': instance.questionIds,
    };
