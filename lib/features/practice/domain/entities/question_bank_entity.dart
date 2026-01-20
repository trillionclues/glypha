import 'package:json_annotation/json_annotation.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';

part 'question_bank_entity.g.dart';

@JsonSerializable()
class QuestionBank {
  final String id;
  final String name;
  final List<String> questionIds;
  final String ownerId;
  final DateTime createdAt;
  final bool isPublic;
  final String? sourceImageUrl;

  QuestionBank({
    required this.id,
    required this.name,
    required this.questionIds,
    required this.ownerId,
    required this.createdAt,
    this.isPublic = false,
    this.sourceImageUrl,
  });

  factory QuestionBank.fromJson(Map<String, dynamic> json) =>
      _$QuestionBankFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionBankToJson(this);

  QuestionBank copyWith({
    String? id,
    String? name,
    List<String>? questionIds,
    String? ownerId,
    DateTime? createdAt,
    bool? isPublic,
    String? sourceImageUrl,
  }) {
    return QuestionBank(
      id: id ?? this.id,
      name: name ?? this.name,
      questionIds: questionIds ?? this.questionIds,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      sourceImageUrl: sourceImageUrl ?? this.sourceImageUrl,
    );
  }
}
