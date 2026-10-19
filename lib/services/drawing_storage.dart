import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class DrawingStorage {
  static const _directoryName = 'pixel_painter';

  Future<Directory> _directory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/$_directoryName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<String> save(Uint8List pngBytes, {String? existingPath}) async {
    final directory = await _directory();
    final path = existingPath ??
        '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(pngBytes);
    return path;
  }

  Future<List<File>> list() async {
    final directory = await _directory();
    final files = (await directory
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.png'))
        .cast<File>()
        .toList())
      ..sort(
        (first, second) =>
            second.statSync().modified.compareTo(first.statSync().modified),
      );
    return files;
  }
}
