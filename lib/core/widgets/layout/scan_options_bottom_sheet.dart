import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const ScanOptionsBottomSheet({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanOptionsBottomSheet(
        onCameraSelected: onCameraSelected,
        onGallerySelected: onGallerySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: bottomPadding > 0 ? bottomPadding : 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Scan Notes',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how you want to capture your notes',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              _OptionTile(
                icon: Icons.camera_alt_rounded,
                title: 'Take Photo',
                subtitle: 'Capture notes with your camera',
                onTap: () {
                  Navigator.pop(context);
                  onCameraSelected();
                },
              ),
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.photo_library_rounded,
                title: 'Upload Photo',
                subtitle: 'Choose from your gallery',
                onTap: () {
                  Navigator.pop(context);
                  onGallerySelected();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? Colors.grey[800] : const Color(0xFFF8FAFC))
                : (isDark ? Colors.grey[900] : const Color(0xFFFAFAFA)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: theme.iconTheme.color ?? const Color(0xFF0F172A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.iconTheme.color?.withOpacity(0.3) ??
                    const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
