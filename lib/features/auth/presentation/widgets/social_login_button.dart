import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SocialLoginType { google, apple }

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = type == SocialLoginType.apple;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isApple ? theme.colorScheme.onBackground : Colors.white,
          foregroundColor:
              isApple ? theme.colorScheme.background : Colors.black87,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          side: isApple
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade200, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isApple ? theme.colorScheme.background : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isApple
                          ? theme.colorScheme.background
                          : Colors.black87,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(isApple, theme),
                  const SizedBox(width: 12),
                  Text(
                    _getButtonText(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isApple
                          ? theme.colorScheme.background
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon(bool isApple, ThemeData theme) {
    return type == SocialLoginType.google
        ? SvgPicture.asset(
            'assets/icons/google.svg',
            height: 22,
            width: 22,
          )
        : Icon(
            Icons.apple,
            size: 22,
            color: theme.colorScheme.background,
          );
  }

  String _getButtonText() {
    return type == SocialLoginType.google
        ? 'Continue with Google'
        : 'Continue with Apple';
  }
}
