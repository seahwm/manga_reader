import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/current_chapter_provider.dart';
import 'package:manga_reader/provider/directory_provider.dart';

import '../screens/chapter_listing.dart';


class Manga extends ConsumerStatefulWidget {
  final String fileDir;

  const Manga(this.fileDir, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MangaState();
  }
}

class _MangaState extends ConsumerState<Manga>{
  @override
  Widget build(BuildContext context) {
    final mangaDir = Directory(widget.fileDir);
    final chapterList = mangaDir.listSync();
    final coverImg = chapterList
        .where((f) => f.path.split('/').last.split('.').first=='index')
        .firstOrNull;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onLongPress: () async {
              if (await confirm(
                context,
                content: Text(
                  'Are you sure want to delete ${widget.fileDir.split('/').last}?',
                ),
              )) {
               ref.read(directoryProvider.notifier).deleteManga(widget.fileDir);
              }
            },
            onTap: () {
              ref.read(currentChapterProvider.notifier).setCurrentChapter(widget.fileDir);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) =>  ChapterListing(widget.fileDir),
                  ),
                );
            },
            child: coverImg != null
                ? Image.file(
              File(coverImg.path),
              fit: BoxFit.fitWidth,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image in Manga widget: $error");
                return const Icon(Icons.error);
              },
            )
                : TextButton.icon(onPressed: null, label: Text('No Image'),icon: Icon(Icons.error),),
          ),
        ),
        Expanded(flex: 1, child: Text(widget.fileDir.split('/').last)),
      ],
    );
  }
}
