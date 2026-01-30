import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gen_ai_provider.g.dart';

class GenAIService {
  final GenerativeModel _ocrModel;
  final GenerativeModel _questionGenModel;

  GenAIService(String apiKey)
      : _ocrModel = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
              'You are an OCR expert. Extract all readable text from the provided image. '
              'Return ONLY the extracted text, no JSON, no formatting, just the raw text content.'),
        ),
        _questionGenModel = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
              'You are an expert educational content creator. Generate 5-10 high-quality questions from the provided text. '
              'IMPORTANT: This is for a FAST-PACED game UI. Keep questions and answers SHORT. '
              '- Prompts: MAX 100 characters. Be concise. '
              '- Options: MAX 25 characters each. Use 2-4 word answers. '
              'Create a mix of question types based on the content. '
              'Always respond with a valid JSON object. '
              'Schema: { "questions": [ { '
              '"prompt": "String - the question text", '
              '"type": "mcq | binary", '
              '"options": ["String"] - EXACTLY 3 options for mcq (NO MORE, NO LESS), 2 for binary, '
              '"correctIndex": int - 0-indexed, '
              '"explanation": "String - brief explanation of the answer", '
              '"difficulty": int - 1 to 5, '
              '"tags": ["String"] - subject/topic tags '
              '} ] }'),
        );

  // Stage 1: Extract raw text from image using OCR
  Future<String> extractTextFromImage(File image) async {
    final bytes = await image.readAsBytes();
    final response = await _ocrModel.generateContent([
      Content.multi([
        TextPart(
            'Extract all text from this image. Return only the text content.'),
        DataPart('image/jpeg', bytes),
      ])
    ]);

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Could not extract text from the image');
    }
    return text.trim();
  }

  // Stage 2: Generate questions from extracted text
  Future<List<Map<String, dynamic>>> generateQuestionsFromText(
      String text) async {
    final response = await _questionGenModel.generateContent([
      Content.text('Generate educational questions from this content:\n\n$text')
    ]);

    final result = _parseResponse(response.text);
    return List<Map<String, dynamic>>.from(result['questions'] ?? []);
  }

  Map<String, dynamic> _parseResponse(String? text) {
    if (text == null) throw Exception('Empty response from AI');

    // Clean potential markdown code blocks
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}

@riverpod
GenAIService genAiService(GenAiServiceRef ref) {
  // const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception(
        'GEMINI_API_KEY not found. Please set it via --dart-define');
  }
  return GenAIService(apiKey);
}
