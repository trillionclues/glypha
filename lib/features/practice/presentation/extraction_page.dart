import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:glypha/features/practice/presentation/provider/gen_ai_provider.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';
import 'package:glypha/features/practice/domain/entities/question_bank_entity.dart';
import 'package:glypha/features/practice/presentation/provider/question_bank_provider.dart';
import 'package:uuid/uuid.dart';

enum ExtractionStage { input, processing, review, error }

class ExtractionPage extends ConsumerStatefulWidget {
  static const String route = '/extraction';
  const ExtractionPage({super.key});

  @override
  ConsumerState<ExtractionPage> createState() => _ExtractionPageState();
}

class _ExtractionPageState extends ConsumerState<ExtractionPage> {
  ExtractionStage _stage = ExtractionStage.input;
  File? _selectedImage;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _bankName = '';
  List<Question> _extractedQuestions = [];
  String _errorMessage = '';

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _startExtraction() async {
    setState(() {
      _stage = ExtractionStage.processing;
    });

    try {
      final genAi = ref.read(genAiServiceProvider);
      final authState = ref.read(authNotifierProvider);
      final userId =
          authState is AuthAuthenticated ? authState.user.id : 'anonymous';

      Map<String, dynamic> result;

      if (_selectedImage != null) {
        result = await genAi.extractFromImage(_selectedImage!);
      } else {
        result = await genAi.extractFromText(_textController.text);
      }

      setState(() {
        _bankName = result['bankName'] ?? 'New Question Bank';
        final List<dynamic> questionsJson = result['questions'] ?? [];
        _extractedQuestions = questionsJson
            .map((q) => Question(
                  id: DateTime.now().millisecondsSinceEpoch.toString() +
                      (questionsJson.indexOf(q)).toString(),
                  prompt: q['prompt'],
                  options: List<String>.from(q['options']),
                  correctIndex: q['correctIndex'],
                  type: q['type'] == 'mcq'
                      ? QuestionType.mcq
                      : QuestionType.binary,
                  ownerId: userId,
                  createdAt: DateTime.now(),
                ))
            .toList();
        _stage = ExtractionStage.review;
      });
    } catch (e) {
      setState(() {
        _stage = ExtractionStage.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveBank() async {
    final authState = ref.read(authNotifierProvider);
    final userId =
        authState is AuthAuthenticated ? authState.user.id : 'anonymous';

    final bank = QuestionBank(
      id: const Uuid().v4(),
      name: _bankName,
      questionIds: _extractedQuestions.map((q) => q.id).toList(),
      ownerId: userId,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(questionBankRepositoryProvider).saveBank(bank);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Extraction',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildStageContent(),
      ),
      bottomNavigationBar:
          _stage == ExtractionStage.input ? _buildInputActions() : null,
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case ExtractionStage.input:
        return _buildInputStage();
      case ExtractionStage.processing:
        return _buildProcessingStage();
      case ExtractionStage.review:
        return _buildReviewStage();
      case ExtractionStage.error:
        return _buildErrorStage();
    }
  }

  Widget _buildErrorStage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              'Extraction Failed',
              style:
                  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() => _stage = ExtractionStage.input),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputStage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provide Study Material',
            style:
                GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of your notes or paste text to convert into a game.',
            style: GoogleFonts.outfit(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_selectedImage!,
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildInputTypeCard(
                    'Camera',
                    Icons.camera_alt_rounded,
                    () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputTypeCard(
                    'Gallery',
                    Icons.image_rounded,
                    () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 32),
          Text(
            'Or Paste Text',
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Paste your study notes here...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTypeCard(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 32),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputActions() {
    final bool canStart =
        _selectedImage != null || _textController.text.length > 20;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ElevatedButton(
        onPressed: canStart ? _startExtraction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text('Generate Questions',
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProcessingStage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                  strokeWidth: 6, color: Color(0xFF6366F1))),
          const SizedBox(height: 32),
          Text(
            'AI is analyzing your content...',
            style:
                GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'This usually takes about 10-15 seconds',
            style: GoogleFonts.outfit(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStage() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _extractedQuestions.length,
            itemBuilder: (context, index) =>
                _buildQuestionCard(_extractedQuestions[index], index),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _stage = ExtractionStage.input),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Redo'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _extractedQuestions.isEmpty ? null : _saveBank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Save Bank',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF6366F1),
                  child: Text('${index + 1}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white))),
              const SizedBox(width: 12),
              Text(
                  question.type == QuestionType.mcq
                      ? 'Multiple Choice'
                      : 'True/False',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.prompt,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...question.options.asMap().entries.map((entry) =>
              _buildOptionPlaceholder(
                  entry.value, entry.key == question.correctIndex)),
        ],
      ),
    );
  }

  Widget _buildOptionPlaceholder(String text, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color:
                isCorrect ? Colors.green.withOpacity(0.3) : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(isCorrect ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 16, color: isCorrect ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 13,
                  color: isCorrect ? Colors.green[800] : Colors.black87)),
        ],
      ),
    );
  }
}
