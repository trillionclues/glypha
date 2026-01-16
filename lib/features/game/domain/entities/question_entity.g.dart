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
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
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
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.mcq: 'mcq',
  QuestionType.binary: 'binary',
  QuestionType.input: 'input',
  QuestionType.matchPair: 'matchPair',
};
