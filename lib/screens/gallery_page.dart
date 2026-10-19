import 'dart:io';

import 'package:flutter/material.dart';

import '../services/drawing_storage.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final Future<List<File>> _files = DrawingStorage().list();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Drawing Gallery')),
        body: FutureBuilder<List<File>>(
          future: _files,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No saved drawings yet\nCreate one in the studio.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .82,
              ),
              itemBuilder: (context, index) {
                final file = snapshot.data![index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, file),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Image.file(file,
                                width: double.infinity, fit: BoxFit.cover)),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('Drawing ${index + 1}',
                                style: Theme.of(context).textTheme.labelLarge)),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Text(
                                '${file.statSync().modified}'.substring(0, 16),
                                style: Theme.of(context).textTheme.labelSmall)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
}
