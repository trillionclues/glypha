import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/core/themes/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:glypha/features/practice/presentation/provider/scan_record_provider.dart';
import 'package:glypha/features/practice/domain/entities/scan_record_entity.dart';
import 'package:glypha/features/practice/presentation/provider/gen_ai_provider.dart';
import 'package:glypha/features/game/data/repositories/question_repository.dart';
import 'package:glypha/features/game/domain/entities/question_entity.dart';
import 'package:glypha/features/game/domain/entities/game_type.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';

class ScanDetailPage extends ConsumerStatefulWidget {
  final String scanId;

  const ScanDetailPage({super.key, required this.scanId});

  @override
  ConsumerState<ScanDetailPage> createState() => _ScanDetailPageState();
}

class _ScanDetailPageState extends ConsumerState<ScanDetailPage> {
  ScanRecord? _scan;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadScan();
  }

  Future<void> _loadScan() async {
    try {
      final repository = ref.read(scanRecordRepositoryProvider);
      final scan = await repository.getScan(widget.scanId);
      setState(() {
        _scan = scan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePublic() async {
    final theme = Theme.of(context);
    if (_scan == null) return;

    final newValue = !_scan!.isPublic;
    try {
      await ref
          .read(scanRecordRepositoryProvider)
          .togglePublic(widget.scanId, newValue);
      setState(() {
        _scan = _scan!.copyWith(isPublic: newValue);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            duration: const Duration(milliseconds: 1000),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteScan() async {
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Scan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this scan?',
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.outfit(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(scanRecordRepositoryProvider).deleteScan(widget.scanId);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              duration: const Duration(milliseconds: 1000),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _copyToClipboard() {
    final theme = Theme.of(context);
    if (_scan == null) return;
    Clipboard.setData(ClipboardData(text: _scan!.extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard', style: GoogleFonts.outfit()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _generateQuestions() async {
    final theme = Theme.of(context);

    if (_scan == null || _isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generating questions...', style: GoogleFonts.outfit()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    try {
      final genAi = ref.read(genAiServiceProvider);
      final authState = ref.read(authNotifierProvider);
      final userId =
          authState is AuthAuthenticated ? authState.user.id : 'anonymous';

      // this generates questions from the extracted text
      // ...and then converts them to question entities
      final questionsData =
          await genAi.generateQuestionsFromText(_scan!.extractedText);

      final questions = questionsData.map((data) {
        var questionType = _parseQuestionType(data['type'] as String? ?? 'mcq');
        var options = List<String>.from(data['options'] ?? []);
        var correctIndex = data['correctIndex'] as int? ?? 0;

        // Sanitize gnerated MCQ to max 3 options (Runner limit)
        if (questionType == QuestionType.mcq && options.length > 3) {
          final correctAnswer = options[correctIndex];
          final otherOptions = List<String>.from(options)
            ..removeAt(correctIndex)
            ..shuffle();

          // Take exactly 2 others to make 3 total
          final keptOptions = otherOptions.take(2).toList();
          final newOptions = [...keptOptions, correctAnswer]..shuffle();

          options = newOptions;
          correctIndex = newOptions.indexOf(correctAnswer);
        }

        final id = const Uuid().v4();

        return Question(
          id: id,
          prompt: data['prompt'] as String? ?? '',
          type: questionType,
          options: options,
          correctIndex: correctIndex,
          explanation: data['explanation'] as String?,
          difficulty: data['difficulty'] as int? ?? 3,
          tags: List<String>.from(data['tags'] ?? []),
          ownerId: userId,
          isPublic: _scan!.isPublic,
          createdAt: DateTime.now(),
          compatibleModes: _determineCompatibleModes(questionType, options),
        );
      }).toList();

      // ...and saves to the allQuestions collection
      await ref.read(questionRepositoryProvider).saveQuestionsBatch(questions);

      final updatedScan = _scan!.copyWith(
        generatedQuestionIds: questions.map((q) => q.id).toList(),
      );
      await ref.read(scanRecordRepositoryProvider).updateScan(updatedScan);

      setState(() {
        _scan = updatedScan;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated ${questions.length} questions!',
                style: GoogleFonts.outfit()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  QuestionType _parseQuestionType(String type) {
    switch (type.toLowerCase()) {
      case 'binary':
        return QuestionType.binary;
      case 'input':
        return QuestionType.input;
      default:
        return QuestionType.mcq;
    }
  }

  List<GameType> _determineCompatibleModes(
      QuestionType type, List<String> options) {
    final modes = <GameType>[];

    switch (type) {
      case QuestionType.binary:
        modes.addAll([GameType.swipe, GameType.runner]);
        break;
      case QuestionType.mcq:
        if (options.length == 2) {
          modes.addAll([GameType.swipe, GameType.runner]);
        } else if (options.length <= 4) {
          modes.addAll([GameType.runner]);
        }
        break;
      case QuestionType.matchPair:
        modes.addAll([GameType.swipe]);
        break;
      case QuestionType.input:
        break;
    }

    if (modes.isEmpty) {
      modes.addAll([GameType.swipe]);
    }

    return modes;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Not Found')),
        body: const Center(child: Text('Could not load scan')),
      );
    }

    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Details',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFDC2626)),
            onPressed: _deleteScan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          color: Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(_scan!.createdAt),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              timeFormat.format(_scan!.createdAt),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visibility',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            _scan!.isPublic
                                ? 'Others can see this scan'
                                : 'Only you can see this',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _scan!.isPublic,
                        onChanged: (_) => _togglePublic(),
                        activeColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  if (_scan!.generatedQuestionIds.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.quiz_rounded,
                            size: 18, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          '${_scan!.generatedQuestionIds.length} questions generated',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                _scan!.extractedText,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: _buildFloatingActionMenu(),
      ),
    );
  }

  Widget _buildFloatingActionMenu() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabMenuOpen) ...[
          if (_scan!.generatedQuestionIds.isEmpty)
            FloatingActionButton.small(
              heroTag: 'fab_generate',
              onPressed: () {
                _generateQuestions();
                setState(() => _isFabMenuOpen = false);
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: const CircleBorder(),
              child: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
            )
          else
            FloatingActionButton.small(
              heroTag: 'fab_generated',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Questions already generated!'),
                    duration: const Duration(milliseconds: 1000),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
                setState(() => _isFabMenuOpen = false);
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: const CircleBorder(),
              child: const Icon(Icons.check_circle_rounded),
            ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'fab_copy',
            onPressed: () {
              _copyToClipboard();
              setState(() => _isFabMenuOpen = false);
            },
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).iconTheme.color,
            shape: const CircleBorder(),
            child: const Icon(Icons.copy_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'fab_share',
            onPressed: () {
              // Share placeholder
              setState(() => _isFabMenuOpen = false);
            },
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).iconTheme.color,
            shape: const CircleBorder(),
            child: const Icon(Icons.ios_share_rounded),
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: () {
            setState(() {
              _isFabMenuOpen = !_isFabMenuOpen;
            });
          },
          backgroundColor: _isFabMenuOpen
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
          foregroundColor: _isFabMenuOpen
              ? theme.colorScheme.onSecondary
              : theme.colorScheme.onPrimary,
          shape: const CircleBorder(),
          child: Icon(_isFabMenuOpen ? Icons.close_rounded : Icons.add_rounded),
        ),
      ],
    );
  }
}
