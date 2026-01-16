import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'pseudo_3d_component.dart';

class GateComponent extends Pseudo3DComponent {
  final String question;
  final List<String> answers; // [Left, Center, Right]
  final int correctAnswerIndex;
  bool hasCollided = false;
  int? collidedLane;

  GateComponent({
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
    required super.worldX,
    required super.worldY,
    required super.worldZ,
  });

  final List<RectangleComponent> _gateRects = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Create answer gates based on available answers
    final gateCount = answers.length;
    for (int i = 0; i < gateCount; i++) {
      // Offset calculation:
      // 1 gate: center (0)
      // 2 gates: -1.25, 1.25
      // 3 gates: -2.5, 0, 2.5
      double laneX;
      if (gateCount == 1) {
        laneX = 0;
      } else if (gateCount == 2) {
        laneX = (i == 0) ? -1.5 : 1.5;
      } else {
        laneX = (i - 1) * 2.5;
      }

      final gateColor = const Color(0xFF2196F3).withOpacity(0.9);

      final gateRect = RectangleComponent(
        position: Vector2(laneX - 1.2, -2.0),
        size: Vector2(2.4, 4.0),
        paint: Paint()..color = gateColor,
        children: [
          TextComponent(
            text: answers[i],
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 0.7,
                fontWeight: FontWeight.bold,
              ),
            ),
            position: Vector2(1.2, 2.0),
            anchor: Anchor.center,
          ),
        ],
      );

      add(gateRect);
      _gateRects.add(gateRect);

      add(RectangleComponent(
        position: Vector2(laneX - 1.25, -2.05),
        size: Vector2(2.5, 4.1),
        paint: Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.15,
      ));
    }
  }

  void showFeedback(int playerLane, bool isCorrect) {
    if (hasCollided) return;
    hasCollided = true;
    collidedLane = playerLane;

    // Change color of the gate the player hit
    final hitGateIndex =
        playerLane + 1; // Convert lane (-1,0,1) to index (0,1,2)

    if (hitGateIndex >= 0 && hitGateIndex < _gateRects.length) {
      final hitGate = _gateRects[hitGateIndex];

      // Change color based on correct/wrong
      final feedbackColor = isCorrect
          ? const Color(0xFF4CAF50).withOpacity(0.9) // Green for correct
          : const Color(0xFFE53935).withOpacity(0.9); // Red for wrong

      hitGate.paint = Paint()..color = feedbackColor;
    }
  }
}
