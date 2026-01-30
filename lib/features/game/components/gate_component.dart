import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'pseudo_3d_component.dart';

class GateComponent extends Pseudo3DComponent {
  final String question;
  final List<String> answers; // [Left, Center, Right] or fewer
  final int correctAnswerIndex;
  bool hasCollided = false;
  bool hasMissed = false;
  int? collidedLane;

  @override
  bool get isRemoved => !isMounted;

  GateComponent({
    required this.question,
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

      add(RectangleComponent(
        position: Vector2(laneX - gateWidth / 2, -2.0),
        size: Vector2(gateWidth, 0.15),
        paint: Paint()..color = const Color(0xFF00E5FF),
      ));

      final textComponent = TextComponent(
        text: _wrapText(answers[i], gateCount == 1 ? 20 : 12),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 0.35,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
            height: 1.2,
            // shadows: [
            //   Shadow(
            //     blurRadius: 2.0,
            //     color: Colors.black,
            //     offset: Offset(1.0, 1.0),
            //   ),
            // ],
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
    String truncated = text;
    final maxTotalChars = maxCharsPerLine * 3;
    if (truncated.length > maxTotalChars) {
      truncated = '${truncated.substring(0, maxTotalChars - 3)}...';
    }

    if (truncated.length <= maxCharsPerLine) return truncated;

    final words = truncated.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      String wordToAdd = word;
      if (word.length > maxCharsPerLine) {
        wordToAdd = '${word.substring(0, maxCharsPerLine - 2)}..';
      }

      if ((currentLine + wordToAdd).length <= maxCharsPerLine) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + wordToAdd;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = wordToAdd;
        } else {
          lines.add(wordToAdd);
          currentLine = '';
        }
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    // Limit to 3 lines max
    if (lines.length > 3) {
      return '${lines.sublist(0, 2).join('\n')}\n${lines[2].substring(0, (lines[2].length > maxCharsPerLine - 3 ? maxCharsPerLine - 3 : lines[2].length))}...';
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
        // Player lane -1 maps to gate 0, player lane 0 maps to gate 1
        if (playerLane == -1 && i == 0) {
          hitGateIndex = 0;
          break;
        } else if (playerLane == 0 && i == 1) {
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
