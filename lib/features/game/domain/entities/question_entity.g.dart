// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      isImagePrompt: json['isImagePrompt'] as bool? ?? false,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      sourceNodeId: json['sourceNodeId'] as String?,
      sourceImageUrl: json['sourceImageUrl'] as String?,
      ownerId: json['ownerId'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      compatibleModes: (json['compatibleModes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GameTypeEnumMap, e))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'prompt': instance.prompt,
      'isImagePrompt': instance.isImagePrompt,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'sourceNodeId': instance.sourceNodeId,
      'sourceImageUrl': instance.sourceImageUrl,
      'ownerId': instance.ownerId,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'compatibleModes':
          instance.compatibleModes.map((e) => _$GameTypeEnumMap[e]!).toList(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.mcq: 'mcq',
  QuestionType.binary: 'binary',
  QuestionType.input: 'input',
  QuestionType.matchPair: 'matchPair',
};

const _$GameTypeEnumMap = {
  GameType.runner: 'runner',
  GameType.swipe: 'swipe',
  GameType.stack: 'stack',
  GameType.match: 'match',
};
