import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'pseudo_3d_component.dart';

class GateComponent extends Pseudo3DComponent {
  final String question;
  final List<String> answers; // [Left, Center, Right] or fewer
  final int correctAnswerIndex;
  bool hasCollided = false;
  int? collidedLane;

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

      if (gateCount == 1) {
        laneX = 0;
        _laneMapping.add(0);
      } else if (gateCount == 2) {
        // Two gates: left (-1.5) and right (1.5)
        laneX = (i == 0) ? -1.5 : 1.5;
        _laneMapping.add(i == 0 ? -1 : 1);
      } else {
        // Three gates: left (-2.5), center (0), right (2.5)
        laneX = (i - 1) * 2.5;
        _laneMapping.add(i - 1);
      }

      final gateColor = const Color(0xFF2196F3).withOpacity(0.9);

      final gateWidth = gateCount == 1 ? 3.0 : 2.4;
      final gateHeight = 4.0;

      final gateRect = RectangleComponent(
        position: Vector2(laneX - gateWidth / 2, -2.0),
        size: Vector2(gateWidth, gateHeight),
        paint: Paint()..color = gateColor,
      );

      add(gateRect);
      _gateRects.add(gateRect);

      final textComponent = TextComponent(
        text: _wrapText(answers[i], gateCount == 1 ? 12 : 8),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 0.5,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        position: Vector2(laneX, 0),
        anchor: Anchor.center,
        size: Vector2(gateWidth * 0.9, gateHeight * 0.9),
      );
      add(textComponent);

      add(RectangleComponent(
        position: Vector2(laneX - (gateWidth / 2 + 0.05), -2.05),
        size: Vector2(gateWidth + 0.1, 4.1),
        paint: Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.15,
      ));
    }
  }

  String _wrapText(String text, int maxCharsPerLine) {
    if (text.length <= maxCharsPerLine) return text;

    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= maxCharsPerLine) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = word;
        } else {
          lines.add(word.substring(0, maxCharsPerLine));
          currentLine = word.substring(maxCharsPerLine);
        }
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
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
        // For 1 or 3 gates, direct mapping
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
}
