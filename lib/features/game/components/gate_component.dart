import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'pseudo_3d_component.dart';

class GateComponent extends Pseudo3DComponent {
  final String question;
  final String questionId;
  final List<String> answers; // [Left, Center, Right] or fewer
  final int correctAnswerIndex;
  bool hasCollided = false;
  bool hasMissed = false;
  int? collidedLane;

  @override
  bool get isRemoved => !isMounted;

  GateComponent({
    required this.question,
    required this.questionId,
    required this.answers,
    required this.correctAnswerIndex,
    required super.worldX,
    required super.worldY,
    required super.worldZ,
  });

  final List<RectangleComponent> _gateRects = [];
  final List<int> _laneMapping = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Create answer gates based on available answers
    final gateCount = answers.length;

    for (int i = 0; i < gateCount; i++) {
      double laneX;
      int mappedLane;

      if (gateCount == 1) {
        laneX = 0;
        mappedLane = 0;
      } else if (gateCount == 2) {
        // Two gates: Use Lane -1 (Left) and Lane 1 (Right). Leave Center empty.
        // Spacing: 1.6 is standard lane width
        laneX = (i == 0) ? -1.6 : 1.6;
        mappedLane = (i == 0) ? -1 : 1;
      } else {
        // Three gates: left (-1.6), center (0), right (1.6)
        laneX = (i - 1) * 1.6;
        mappedLane = i - 1;
      }

      _laneMapping.add(mappedLane);

      final gateWidth = gateCount == 1 ? 3.0 : 1.5;
      final gateHeight = 4.0;

      // Gate frame (outline)
      final gateFrame = RectangleComponent(
        position: Vector2(laneX - gateWidth / 2, -2.0),
        size: Vector2(gateWidth, gateHeight),
        paint: Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.08,
      );
      add(gateFrame);
      _gateRects.add(gateFrame);

      add(RectangleComponent(
        position: Vector2(laneX - gateWidth / 2, -2.0),
        size: Vector2(gateWidth, gateHeight),
        paint: Paint()
          ..color = const Color(0xFF0F172A).withOpacity(0.85)
          ..style = PaintingStyle.fill,
      ));

      // Gate top bar (cyan accent)
      add(RectangleComponent(
        position: Vector2(laneX - gateWidth / 2, -2.0),
        size: Vector2(gateWidth, 0.15),
        paint: Paint()..color = const Color(0xFF00E5FF),
      ));

      final maxCharsPerLine = gateCount == 1 ? 18 : 10;
      final wrappedText = _wrapText(answers[i], maxCharsPerLine);

      final textComponent = TextComponent(
        text: wrappedText,
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.white,
            fontSize: 0.35,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
            height: 1.2,
            shadows: [
              Shadow(
                blurRadius: 0.02,
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(0.01, 0.01),
              ),
            ],
          ),
        ),
        position: Vector2(laneX, 0),
        anchor: Anchor.center,
        priority: 10,
      );

      add(textComponent);
    }
  }

  String _wrapText(String text, int maxCharsPerLine) {
    if (text.length <= maxCharsPerLine) {
      return text;
    }

    // Truncate if too long (max 3 lines)
    final maxTotalChars = maxCharsPerLine * 3;
    String workingText = text;
    if (text.length > maxTotalChars) {
      workingText = '${text.substring(0, maxTotalChars - 3)}...';
    }

    final words = workingText.split(' ');
    final lines = <String>[];
    String currentLine = '';

    for (final word in words) {
      String wordToAdd = word;
      if (word.length > maxCharsPerLine) {
        wordToAdd = '${word.substring(0, maxCharsPerLine - 2)}..';
      }

      final testLine =
          currentLine.isEmpty ? wordToAdd : '$currentLine $wordToAdd';

      if (testLine.length <= maxCharsPerLine) {
        currentLine = testLine;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = wordToAdd;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    if (lines.length > 3) {
      final truncatedLine = lines[2];
      final maxLineLength = maxCharsPerLine - 3;
      lines[2] = truncatedLine.length > maxLineLength
          ? '${truncatedLine.substring(0, maxLineLength)}...'
          : truncatedLine;
      return lines.sublist(0, 3).join('\n');
    }

    return lines.join('\n');
  }

  void showFeedback(int playerLane, bool isCorrect) {
    if (hasCollided) return;
    hasCollided = true;
    collidedLane = playerLane;

    int? hitGateIndex;

    for (int i = 0; i < _laneMapping.length; i++) {
      if (answers.length == 2) {
        // For 2 gates, map player lane to gate index
        // Player lane -1 maps to gate 0, player lane 1 maps to gate 1
        if (playerLane == -1 && i == 0) {
          hitGateIndex = 0;
          break;
        } else if (playerLane == 1 && i == 1) {
          hitGateIndex = 1;
          break;
        }
      } else {
        if (_laneMapping[i] == playerLane) {
          hitGateIndex = i;
          break;
        }
      }
    }

    if (hitGateIndex != null &&
        hitGateIndex >= 0 &&
        hitGateIndex < _gateRects.length) {
      final hitGate = _gateRects[hitGateIndex];

      final feedbackColor = isCorrect
          ? const Color(0xFF4CAF50).withOpacity(0.9)
          : const Color(0xFFE53935).withOpacity(0.9);

      hitGate.paint = Paint()..color = feedbackColor;
    }
  }

  void showMissFeedback() {
    // Dim all gates to show they were missed
    for (final rect in _gateRects) {
      rect.paint = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1;
    }
  }
}
