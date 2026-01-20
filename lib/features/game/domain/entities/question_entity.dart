import 'package:json_annotation/json_annotation.dart';

part 'question_entity.g.dart';

/// Represents the type of question for game mode selection
enum QuestionType {
  /// Multiple choice (2-4 options)
  mcq,

  /// True/False or Yes/No
  binary,

  /// Text input answer
  input,

  /// Pair for memory games
  matchPair,
}

@JsonSerializable()
class Question {
  final String id;

  /// Question text or image URL
  final String prompt;

  /// Whether prompt is text or image
  final bool isImagePrompt;

  final QuestionType type;

  /// Answer options (for MCQ/Binary)
  final List<String> options;

  /// Index of correct answer in options
  final int correctIndex;

  /// Explanation shown after answering
  final String? explanation;

  /// 1-5 difficulty rating
  final int difficulty;

  /// Subject/topic tags
  final List<String> tags;

  /// Links to level/mission node
  final String? sourceNodeId;

  /// For OCR-generated, link to original note image
  final String? sourceImageUrl;

  /// 'SYSTEM' for curated, or userId for user-generated
  final String ownerId;

  final bool isPublic;

  final DateTime createdAt;

  const Question({
    required this.id,
    required this.prompt,
    this.isImagePrompt = false,
    required this.type,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.difficulty = 3,
    this.tags = const [],
    this.sourceNodeId,
    this.sourceImageUrl,
    required this.ownerId,
    this.isPublic = true,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  /// Helper to get the correct answer text
  String get correctAnswer => options[correctIndex];

  /// Check if an answer index is correct
  bool isCorrect(int answerIndex) => answerIndex == correctIndex;
}
