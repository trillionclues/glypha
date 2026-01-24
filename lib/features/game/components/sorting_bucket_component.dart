import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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

    final glassPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final binBody = _BinShapeComponent(
      size: size,
      fillPaint: glassPaint,
      borderPaint: borderPaint,
    );
    add(binBody);

    final iconCode = _getIconForCategory(category);
    add(TextComponent(
      text: String.fromCharCode(iconCode.codePoint),
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: iconCode.fontFamily,
          fontSize: 32,
          color: color.withOpacity(0.9),
          package: iconCode.fontPackage,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2 - 10),
      anchor: Anchor.center,
    ));

    add(TextComponent(
      text: category.toUpperCase(),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      position: Vector2(size.x / 2, size.y - 15),
      anchor: Anchor.center,
    ));
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruit':
        return Icons.local_florist;
      case 'vegetable':
        return Icons.grass;
      case 'mammal':
        return Icons.pets;
      case 'reptile':
        return Icons.bug_report;
      case 'bird':
        return Icons.flight;
      case 'tech':
        return Icons.computer;
      case 'hardware':
        return Icons.memory;
      case 'software':
        return Icons.code;
      default:
        return Icons.category;
    }
  }
}

class _BinShapeComponent extends PositionComponent {
  final Paint fillPaint;
  final Paint borderPaint;

  _BinShapeComponent({
    required Vector2 size,
    required this.fillPaint,
    required this.borderPaint,
  }) : super(size: size);

  @override
  void render(ui.Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.15, h)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    final glowRect = Rect.fromLTWH(w * 0.2, h - 5, w * 0.6, 2);
    canvas.drawOval(glowRect,
        fillPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }
}
