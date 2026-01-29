import 'package:json_annotation/json_annotation.dart';

part 'scan_record_entity.g.dart';

@JsonSerializable()
class ScanRecord {
  final String id;
  final String userId;
  final String extractedText;
  final bool isPublic;
  final DateTime createdAt;
  final String? sourceImageUrl;

  // IDs of questions generated from ocr scan (populated after background gen)
  final List<String> generatedQuestionIds;

  const ScanRecord({
    required this.id,
    required this.userId,
    required this.extractedText,
    this.isPublic = false,
    required this.createdAt,
    this.sourceImageUrl,
    this.generatedQuestionIds = const [],
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) =>
      _$ScanRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ScanRecordToJson(this);

  ScanRecord copyWith({
    String? id,
    String? userId,
    String? extractedText,
    bool? isPublic,
    DateTime? createdAt,
    String? sourceImageUrl,
    List<String>? generatedQuestionIds,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      extractedText: extractedText ?? this.extractedText,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      sourceImageUrl: sourceImageUrl ?? this.sourceImageUrl,
      generatedQuestionIds: generatedQuestionIds ?? this.generatedQuestionIds,
    );
  }

  // preview of the extracted text
  String get textPreview {
    if (extractedText.length <= 100) return extractedText;
    return '${extractedText.substring(0, 1000)}...';
  }
}
