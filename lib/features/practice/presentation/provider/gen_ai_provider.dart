import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';

part 'gen_ai_provider.g.dart';

class GenAIService {
  final GenerativeModel _model;

  GenAIService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
              'You are an expert educational content creator. Your task is to extract 5-10 high-quality multiple-choice questions from the provided document (image or text). '
              'Always respond with a valid JSON object. '
              'Schema: { "bankName": "String", "questions": [ { "prompt": "String", "options": ["String"], "correctIndex": int, "type": "mcq" } ] }'),
        );

  Future<Map<String, dynamic>> extractFromText(String text) async {
    final response = await _model.generateContent([Content.text(text)]);
    return _parseResponse(response.text);
  }

  Future<Map<String, dynamic>> extractFromImage(File image) async {
    final bytes = await image.readAsBytes();
    final response = await _model.generateContent([
      Content.multi([
        TextPart('Extract questions from this document.'),
        DataPart('image/jpeg', bytes),
      ])
    ]);
    return _parseResponse(response.text);
  }

  Map<String, dynamic> _parseResponse(String? text) {
    if (text == null) throw Exception('Empty response from AI');

    // Clean potential markdown code blocks
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7, cleaned.length - 3).trim();
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3, cleaned.length - 3).trim();
    }

    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}

@riverpod
GenAIService genAiService(GenAiServiceRef ref) {
  // TODO: Get API Key from secure storage or env
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  if (apiKey.isEmpty) {
    throw Exception(
        'GEMINI_API_KEY not found. Please set it via --dart-define');
  }
  return GenAIService(apiKey);
}
