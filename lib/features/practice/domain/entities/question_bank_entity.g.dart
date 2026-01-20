// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bank_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionBank _$QuestionBankFromJson(Map<String, dynamic> json) => QuestionBank(
      id: json['id'] as String,
      name: json['name'] as String,
      questionIds: (json['questionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      sourceImageUrl: json['sourceImageUrl'] as String?,
    );

Map<String, dynamic> _$QuestionBankToJson(QuestionBank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'questionIds': instance.questionIds,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'isPublic': instance.isPublic,
      'sourceImageUrl': instance.sourceImageUrl,
    };
