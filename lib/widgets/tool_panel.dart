import 'package:flutter/material.dart';

import '../models/tool.dart';

class ToolPanel extends StatelessWidget {
  const ToolPanel({
    required this.selectedTool,
    required this.color,
    required this.width,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onWidthChanged,
    super.key,
  });

  final Tool selectedTool;
  final Color color;
  final double width;
  final ValueChanged<Tool> onToolChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;

  static const swatches = [
    Color(0xff22243a),
    Color(0xffef476f),
    Color(0xffff9f1c),
    Color(0xffffd166),
    Color(0xff06d6a0),
    Color(0xff118ab2),
    Color(0xff6c4cff),
    Color(0xffffffff),
  ];

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 67,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: Tool.values
                      .map((tool) => Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ChoiceChip(
                              avatar: Icon(tool.icon, size: 18),
                              label: Text(tool.label),
                              selected: selectedTool == tool,
                              onSelected: (_) => onToolChanged(tool),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Row(children: [
                const Text('Size'),
                Expanded(
                    child: Slider(
                        value: width,
                        min: 3,
                        max: 36,
                        divisions: 11,
                        label: width.round().toString(),
                        onChanged: onWidthChanged)),
                Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26))),
              ]),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: swatches
                      .map((swatch) => Padding(
                            padding: const EdgeInsets.only(right: 9),
                            child: InkWell(
                              onTap: () => onColorChanged(swatch),
                              child: Container(
                                  width: 28,
                                  decoration: BoxDecoration(
                                      color: swatch,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: color == swatch
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.black26,
                                          width: color == swatch ? 3 : 1))),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
}
