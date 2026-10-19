import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/stroke_action.dart';
import '../models/tool.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter(
      {required this.base, required this.actions, required this.active});

  final ui.Image? base;
  final List<StrokeAction> actions;
  final StrokeAction? active;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.src);
    if (base != null) {
      canvas.drawImageRect(
        base!,
        Rect.fromLTWH(0, 0, base!.width.toDouble(), base!.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
    }
    for (final action in actions) {
      _draw(canvas, action);
    }
    if (active != null) {
      _draw(canvas, active!);
    }
  }

  void _draw(Canvas canvas, StrokeAction action) {
    final paint = Paint()
      ..color = action.color
      ..strokeWidth = action.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final end = action.end;

    if (action.tool == Tool.brush || action.tool == Tool.eraser) {
      if (action.points.length == 1) {
        canvas.drawCircle(
          action.points.first,
          action.width / 2,
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path()
          ..moveTo(action.points.first.dx, action.points.first.dy);
        for (final point in action.points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, paint);
      }
      return;
    }

    if (action.tool == Tool.spray) {
      final random = Random(action.points.length);
      for (final point in action.points) {
        for (var index = 0; index < (action.width * 1.5).round(); index++) {
          final radius = sqrt(random.nextDouble()) * action.width;
          final angle = random.nextDouble() * pi * 2;
          canvas.drawCircle(
            point + Offset(cos(angle) * radius, sin(angle) * radius),
            max(1, action.width / 8),
            paint..style = PaintingStyle.fill,
          );
        }
      }
      return;
    }

    if (end == null) {
      return;
    }
    final start = action.points.first;
    final rect = Rect.fromPoints(start, end);
    switch (action.tool) {
      case Tool.line:
        canvas.drawLine(start, end, paint);
      case Tool.rectangle:
        canvas.drawRect(rect, paint);
      case Tool.ellipse:
        canvas.drawOval(rect, paint);
      case Tool.triangle:
        final path = Path()
          ..moveTo((start.dx + end.dx) / 2, start.dy)
          ..lineTo(end.dx, end.dy)
          ..lineTo(start.dx, end.dy)
          ..close();
        canvas.drawPath(path, paint);
      case Tool.brush:
      case Tool.spray:
      case Tool.eraser:
      case Tool.fill:
        break;
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}
