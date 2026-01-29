import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/core/themes/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glypha/features/practice/presentation/provider/scan_record_provider.dart';
import 'package:glypha/features/practice/domain/entities/scan_record_entity.dart';
import 'package:glypha/features/practice/presentation/extraction_page.dart';
import 'package:glypha/features/practice/presentation/scan_detail_page.dart';
import 'package:glypha/core/widgets/layout/scan_options_bottom_sheet.dart';
import 'package:intl/intl.dart';

class QuestionsPage extends ConsumerWidget {
  static const String route = '/questions';
  const QuestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scansAsync = ref.watch(userScansProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Note Scans',
          style: GoogleFonts.outfit(
            color: AppTheme.darkBackground,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: AppTheme.lightOrange, size: 20),
            ),
            onPressed: () {
              // Settings (not implemented yet)
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: scansAsync.when(
        data: (scans) => scans.isEmpty
            ? _buildEmptyState(context)
            : _buildScanList(context, scans),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showScanOptions(context),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.document_scanner_rounded,
                  size: 48,
                  color: AppTheme.lightOrange.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No scans yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the icon above to scan your first handwritten note or digital photo 🙂',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanList(BuildContext context, List<ScanRecord> scans) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: scans.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scan = scans[index];
        return _buildScanCard(context, scan);
      },
    );
  }

  Widget _buildScanCard(BuildContext context, ScanRecord scan) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailPage(scanId: scan.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(scan.createdAt),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        timeFormat.format(scan.createdAt),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scan.isPublic
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFF64748B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scan.isPublic ? 'Public' : 'Private',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scan.isPublic
                          ? const Color(0xFF059669)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scan.textPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            if (scan.generatedQuestionIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '${scan.generatedQuestionIds.length} questions generated',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showScanOptions(BuildContext context) {
    ScanOptionsBottomSheet.show(
      context,
      onCameraSelected: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExtractionPage(useCamera: true),
          ),
        );
      },
      onGallerySelected: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExtractionPage(useCamera: false),
          ),
        );
      },
    );
  }
}
