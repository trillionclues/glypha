import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:glypha/core/themes/app_theme.dart';
import 'package:glypha/features/practice/presentation/provider/gen_ai_provider.dart';
import 'package:glypha/features/practice/presentation/provider/scan_record_provider.dart';
import 'package:glypha/features/practice/domain/entities/scan_record_entity.dart';
import 'package:glypha/features/auth/presentation/provider/auth_notifier.dart';
import 'package:glypha/features/auth/presentation/provider/auth_state.dart';

enum ExtractionStage { capture, processing, result, error }

class ExtractionPage extends ConsumerStatefulWidget {
  static const String route = '/extraction';
  final bool useCamera;

  const ExtractionPage({super.key, this.useCamera = false});

  @override
  ConsumerState<ExtractionPage> createState() => _ExtractionPageState();
}

class _ExtractionPageState extends ConsumerState<ExtractionPage> {
  ExtractionStage _stage = ExtractionStage.capture;
  File? _selectedImage;
  String _extractedText = '';
  String _errorMessage = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Auto-open camera or gallery based on parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage(widget.useCamera ? ImageSource.camera : ImageSource.gallery);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _startExtraction();
      } else {
        // User cancelled, go back
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _stage = ExtractionStage.error;
        _errorMessage =
            'Could not access camera/gallery. Please check permissions.';
      });
    }
  }

  Future<void> _startExtraction() async {
    if (_selectedImage == null) return;

    setState(() {
      _stage = ExtractionStage.processing;
    });

    try {
      final genAi = ref.read(genAiServiceProvider);
      final text = await genAi.extractTextFromImage(_selectedImage!);

      setState(() {
        _extractedText = text;
        _stage = ExtractionStage.result;
      });
    } catch (e) {
      setState(() {
        _stage = ExtractionStage.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveScan() async {
    final authState = ref.read(authNotifierProvider);
    final userId =
        authState is AuthAuthenticated ? authState.user.id : 'anonymous';

    final scan = ScanRecord(
      id: const Uuid().v4(),
      userId: userId,
      extractedText: _extractedText,
      isPublic: false,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(scanRecordRepositoryProvider).saveScan(scan);
      if (mounted) {
        Navigator.pop(context, scan);
      }
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
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: _stage == ExtractionStage.result
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Result',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  )),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                  onPressed: _saveScan,
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStageContent(),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case ExtractionStage.capture:
        return _buildCaptureStage();
      case ExtractionStage.processing:
        return _buildProcessingStage();
      case ExtractionStage.result:
        return _buildResultStage();
      case ExtractionStage.error:
        return _buildErrorStage();
    }
  }

  Widget _buildCaptureStage() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildProcessingStage() {
    return Stack(
      children: [
        if (_selectedImage != null)
          SizedBox.expand(
            child: Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.cover,
            ),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              const SizedBox(height: 32),
              Text(
                'Processing your notes...',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Extracting text from image',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultStage() {
    return Column(
      children: [
        // (Preview only for now)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Preview',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // add Raw tab later
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Raw',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // add Photo tab later
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Photo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // extracted text content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SelectableText(
              _extractedText,
              style: GoogleFonts.outfit(
                fontSize: 16,
                height: 1.6,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Copy to clipboard
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text('Copy',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF374151),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share functionality
                  },
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text('Share',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorStage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: AppTheme.primaryOrange, size: 38),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back_rounded, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
