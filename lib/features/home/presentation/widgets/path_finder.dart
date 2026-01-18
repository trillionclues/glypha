import 'package:flutter/material.dart';
import 'package:glypha/features/home/data/model/level_data.dart';

class DashedRoadPathPainter extends CustomPainter {
  final List<LevelData> levels;
  final double screenWidth;

  DashedRoadPathPainter(this.levels, this.screenWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath();

    final roadPaint = Paint()
      ..color = const Color(0xFFD1B899).withOpacity(0.4)
      ..strokeWidth = 35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, roadPaint);

    final centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, path, centerLinePaint,
        dashLength: 20, gapLength: 15);

    final completedPath = _buildCompletedPath();

    final completedRoadPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..strokeWidth = 35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(completedPath, completedRoadPaint);

    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 38
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(completedPath, edgePaint);
    canvas.drawPath(completedPath, completedRoadPaint);

    final completedCenterPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, completedPath, completedCenterPaint,
        dashLength: 20, gapLength: 15);
  }

  Path _buildPath() {
    final path = Path();
    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      final x = screenWidth * level.xPosition;
      final y = (levels.length - i) * 180.0 + 90;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevLevel = levels[i - 1];
        final prevX = screenWidth * prevLevel.xPosition;
        final prevY = (levels.length - (i - 1)) * 180.0 + 90;
        final controlX = (x + prevX) / 2;
        final controlY = (y + prevY) / 2 - 40;
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }
    return path;
  }

  Path _buildCompletedPath() {
    final path = Path();
    bool hasStarted = false;

    for (int i = 0; i < levels.length; i++) {
      if (!levels[i].isCompleted) break;

      final level = levels[i];
      final x = screenWidth * level.xPosition;
      final y = (levels.length - i) * 180.0 + 90;

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        final prevLevel = levels[i - 1];
        final prevX = screenWidth * prevLevel.xPosition;
        final prevY = (levels.length - (i - 1)) * 180.0 + 90;
        final controlX = (x + prevX) / 2;
        final controlY = (y + prevY) / 2 - 40;
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {required double dashLength, required double gapLength}) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(distance + dashLength);
        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, paint);
        }
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
