import 'package:flutter/material.dart';

enum Tool { brush, spray, eraser, line, rectangle, ellipse, triangle, fill }

extension ToolInfo on Tool {
  String get label => switch (this) {
        Tool.brush => 'Brush',
        Tool.spray => 'Spray',
        Tool.eraser => 'Eraser',
        Tool.line => 'Line',
        Tool.rectangle => 'Rectangle',
        Tool.ellipse => 'Ellipse',
        Tool.triangle => 'Triangle',
        Tool.fill => 'Fill',
      };

  IconData get icon => switch (this) {
        Tool.brush => Icons.brush_rounded,
        Tool.spray => Icons.grain_rounded,
        Tool.eraser => Icons.cleaning_services_rounded,
        Tool.line => Icons.show_chart_rounded,
        Tool.rectangle => Icons.rectangle_outlined,
        Tool.ellipse => Icons.circle_outlined,
        Tool.triangle => Icons.change_history_rounded,
        Tool.fill => Icons.format_color_fill_rounded,
      };
}
