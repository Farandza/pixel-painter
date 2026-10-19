import 'dart:ui' as ui;

import 'stroke_action.dart';

class CanvasSnapshot {
  CanvasSnapshot(this.base, this.actions);

  final ui.Image? base;
  final List<StrokeAction> actions;
}
