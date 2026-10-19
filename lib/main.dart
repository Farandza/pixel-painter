import 'package:flutter/material.dart';

import 'screens/studio_page.dart';

void main() => runApp(const PixelPainterApp());

class PixelPainterApp extends StatelessWidget {
  const PixelPainterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pixel Painter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6c4cff)),
          useMaterial3: true,
        ),
        home: const StudioPage(),
      );
}
