// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_painter/main.dart';

void main() {
  testWidgets('studio loads drawing controls', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PixelPainterApp());

    // Verify that our counter starts at 0.
    expect(find.text('Pixel Painter'), findsOneWidget);
    expect(find.text('Brush'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
  });
}
