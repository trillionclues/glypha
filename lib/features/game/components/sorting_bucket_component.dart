import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SortingBucketComponent extends PositionComponent {
  final String category;
  final Color color;

  SortingBucketComponent({
    required this.category,
    required this.color,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Bucket Shape (slightly tapered top)
    final bucketPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    add(RectangleComponent(
      size: size,
      paint: bucketPaint,
    ));

    // Top Border
    add(RectangleComponent(
      size: Vector2(size.x, 4),
      position: Vector2(0, 0),
      paint: Paint()..color = color,
    ));

    // Category Label
    add(TextComponent(
      text: category,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  bool containsPosition(Vector2 pos) {
    return pos.x >= position.x - size.x / 2 &&
        pos.x <= position.x + size.x / 2 &&
        pos.y >= position.y - size.y / 2;
  }
}
