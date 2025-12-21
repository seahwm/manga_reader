import 'dart:typed_data';

import 'package:docman/docman.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:manga_reader/screens/chapter_listing.dart';
import 'package:manga_reader/utils/app_utils.dart';

class Manga extends ConsumerWidget {
  final indexUriProvider = StateProvider<Uint8List?>((ref) => null);
  final DocumentFile fileDir;
  DocumentFile? indexFile;

  Manga(this.fileDir, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = ref.watch(indexUriProvider);
    if (uri == null) {
      mangaBoc.findByUri(fileDir.uri).then((manga) {
        if (manga != null &&
            manga!.indexUri != null &&
            manga!.indexUri!.isNotEmpty) {
          debugPrint('Hit sql');
          DocumentFile.fromUri(manga!.indexUri!).then((val) {
            val!.read().then(
              (bytes) => {ref.read(indexUriProvider.notifier).state = bytes},
            );
          });
        } else {
          debugPrint('No hit sql');
          fileDir.listDocuments().then((docs) {
            if (docs.isNotEmpty) {
              indexFile = docs
                  .where((doc) => doc.name.contains('index'))
                  .firstOrNull;
              if (indexFile == null) {
                debugPrint('no found Img');
                ref.read(indexUriProvider.notifier).state = null;
                return;
              }
              debugPrint('found Img');
              if (manga != null) {
                debugPrint('insert db Img');
                manga!.indexUri = indexFile!.uri;
                mangaBoc.update(manga);
              }
              indexFile!.read().then(
                (bytes) => {ref.read(indexUriProvider.notifier).state = bytes},
              );
            }
          });
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (uri != null)
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ChapterListing(fileDir),
                  ),
                );
              },
              child: Image.memory(
                uri,
                fit: BoxFit.fitWidth,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image in Manga widget: $error");
                  return Icon(Icons.error); // Placeholder for error
                },
              ),
            ),
          ),
        Expanded(flex: 1, child: Text(fileDir.name)),
      ],
    );
  }
}
