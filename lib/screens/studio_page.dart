import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/canvas_snapshot.dart';
import '../models/stroke_action.dart';
import '../models/tool.dart';
import '../painters/canvas_painter.dart';
import '../services/drawing_storage.dart';
import '../widgets/tool_panel.dart';
import 'gallery_page.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key, this.editFile});

  final File? editFile;

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  final _canvasKey = GlobalKey();
  final _actions = <StrokeAction>[];
  final _history = <CanvasSnapshot>[];
  final _storage = DrawingStorage();

  Tool _tool = Tool.brush;
  Color _color = const Color(0xff22243a);
  double _width = 7;
  StrokeAction? _active;
  ui.Image? _base;
  Size _canvasSize = Size.zero;
  String? _currentPath;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.editFile != null) {
      _loadFile(widget.editFile!);
    }
  }

  Future<void> _loadFile(File file) async {
    final decoded = Completer<ui.Image>();
    ui.decodeImageFromList(await file.readAsBytes(), decoded.complete);
    final image = await decoded.future;
    if (!mounted) {
      return;
    }
    setState(() {
      _base = image;
      _currentPath = file.path;
    });
  }

  void _snapshot() {
    _history.add(CanvasSnapshot(
        _base, _actions.map((action) => action.copy()).toList()));
    if (_history.length > 20) {
      _history.removeAt(0);
    }
  }

  void _undo() => setState(() {
        if (_history.isEmpty) {
          return;
        }
        final snapshot = _history.removeLast();
        _base = snapshot.base;
        _actions
          ..clear()
          ..addAll(snapshot.actions);
      });

  void _start(Offset point) {
    if (_busy) {
      return;
    }
    if (_tool == Tool.fill) {
      _fill(point);
      return;
    }
    _snapshot();
    setState(() {
      _active = StrokeAction(
        tool: _tool,
        color: _tool == Tool.eraser ? Colors.white : _color,
        width: _width,
        points: [point],
      );
    });
  }

  void _move(Offset point) {
    final active = _active;
    if (active == null) {
      return;
    }
    setState(() {
      if (active.tool == Tool.brush ||
          active.tool == Tool.eraser ||
          active.tool == Tool.spray) {
        active.points.add(point);
      } else {
        _active = StrokeAction(
            tool: active.tool,
            color: active.color,
            width: active.width,
            points: active.points,
            end: point);
      }
    });
  }

  void _end(Offset point) {
    if (_active == null) {
      return;
    }
    _move(point);
    setState(() {
      _actions.add(_active!);
      _active = null;
    });
  }

  Future<ui.Image?> _captureImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    return boundary?.toImage(pixelRatio: 1);
  }

  Future<void> _fill(Offset point) async {
    if (_canvasSize.isEmpty) {
      return;
    }
    setState(() => _busy = true);
    final image = await _captureImage();
    final pixels = await image?.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (image == null || pixels == null) {
      if (mounted) {
        setState(() => _busy = false);
      }
      return;
    }

    final width = image.width;
    final height = image.height;
    final x = point.dx.clamp(0, width - 1).toInt();
    final y = point.dy.clamp(0, height - 1).toInt();
    final data = pixels.buffer.asUint8List();
    final start = (y * width + x) * 4;
    final target = List<int>.generate(4, (index) => data[start + index]);
    final replacement = [
      (_color.r * 255).round(),
      (_color.g * 255).round(),
      (_color.b * 255).round(),
      (_color.a * 255).round(),
    ];
    if (List.generate(4, (index) => target[index] == replacement[index])
        .every((value) => value)) {
      if (mounted) {
        setState(() => _busy = false);
      }
      return;
    }

    final queue = <int>[y * width + x];
    bool matches(int position) =>
        data[position * 4] == target[0] &&
        data[position * 4 + 1] == target[1] &&
        data[position * 4 + 2] == target[2] &&
        data[position * 4 + 3] == target[3];
    for (var head = 0; head < queue.length; head++) {
      final position = queue[head];
      if (!matches(position)) {
        continue;
      }
      data.setRange(position * 4, position * 4 + 4, replacement);
      final pixelX = position % width;
      if (pixelX > 0) queue.add(position - 1);
      if (pixelX < width - 1) queue.add(position + 1);
      if (position >= width) queue.add(position - width);
      if (position < width * (height - 1)) queue.add(position + width);
    }

    final decoded = Completer<ui.Image>();
    ui.decodeImageFromPixels(
        data, width, height, ui.PixelFormat.rgba8888, decoded.complete);
    final filled = await decoded.future;
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot();
      _base = filled;
      _actions.clear();
      _busy = false;
    });
  }

  Future<void> _save({bool copy = false}) async {
    setState(() => _busy = true);
    final image = await _captureImage();
    final bytes = await image?.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      if (mounted) {
        setState(() => _busy = false);
      }
      return;
    }
    final path = await _storage.save(bytes.buffer.asUint8List(),
        existingPath: copy ? null : _currentPath);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentPath = path;
      _busy = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Drawing saved locally')));
  }

  Future<void> _openGallery() async {
    final file = await Navigator.of(context)
        .push<File>(MaterialPageRoute(builder: (_) => const GalleryPage()));
    if (file != null && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StudioPage(editFile: file)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Pixel Painter'),
          actions: [
            IconButton(
                onPressed: _history.isEmpty || _busy ? null : _undo,
                tooltip: 'Undo',
                icon: const Icon(Icons.undo_rounded)),
            IconButton(
                onPressed: _busy ? null : _openGallery,
                tooltip: 'Gallery',
                icon: const Icon(Icons.photo_library_outlined)),
            PopupMenuButton<String>(
              onSelected: (value) => _save(copy: value == 'copy'),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'save', child: Text('Save drawing')),
                PopupMenuItem(value: 'copy', child: Text('Save copy')),
              ],
              icon: const Icon(Icons.save_outlined),
            ),
          ],
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            return Center(
                child: RepaintBoundary(
              key: _canvasKey,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => _start(details.localPosition),
                onPanUpdate: (details) => _move(details.localPosition),
                onPanEnd: (details) => _end(details.localPosition),
                onTapDown: (details) {
                  if (_tool == Tool.fill) _start(details.localPosition);
                },
                child: CustomPaint(
                    size: _canvasSize,
                    painter: CanvasPainter(
                        base: _base, actions: _actions, active: _active)),
              ),
            ));
          })),
          if (_busy) const LinearProgressIndicator(),
          ToolPanel(
              selectedTool: _tool,
              color: _color,
              width: _width,
              onToolChanged: (tool) => setState(() => _tool = tool),
              onColorChanged: (color) => setState(() => _color = color),
              onWidthChanged: (width) => setState(() => _width = width)),
        ])),
      );
}
