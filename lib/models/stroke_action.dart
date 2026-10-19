import 'package:flutter/material.dart';

import 'tool.dart';

class StrokeAction {
  StrokeAction({
    required this.tool,
    required this.color,
    required this.width,
    required this.points,
    this.end,
  });

  final Tool tool;
  final Color color;
  final double width;
  final List<Offset> points;
  final Offset? end;

  StrokeAction copy() => StrokeAction(
        tool: tool,
        color: color,
        width: width,
        points: List.of(points),
        end: end,
      );
}
