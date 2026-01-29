// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanRecord _$ScanRecordFromJson(Map<String, dynamic> json) => ScanRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      extractedText: json['extractedText'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sourceImageUrl: json['sourceImageUrl'] as String?,
      generatedQuestionIds: (json['generatedQuestionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ScanRecordToJson(ScanRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'extractedText': instance.extractedText,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'sourceImageUrl': instance.sourceImageUrl,
      'generatedQuestionIds': instance.generatedQuestionIds,
    };
