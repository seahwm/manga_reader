import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/current_chapter_provider.dart';
import 'package:manga_reader/provider/directory_provider.dart';
import 'package:manga_reader/utils/app_utils.dart';

import '../screens/chapter_listing.dart';
import '../screens/manga_detail.dart';


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
    final listSync = mangaDir.listSync();

    // Check if there are any chapters (subdirectories)
    final hasChapters = listSync.any((f) => Directory(f.path).existsSync());

    FileSystemEntity? coverImg = listSync
        .where((f) => f.path.split('/').last.split('.').first=='index')
        .firstOrNull;

    // Fallback: If no index.jpg, use the first image available
    if (coverImg == null && !hasChapters) {
      final imgList = listSync.where((f) => AppUtils.imgExtensions.contains(f.path.split('.').last)).toList();
      if (imgList.isNotEmpty) {
        imgList.sort((a, b) => Comparable.compare(a.path, b.path));
        coverImg = imgList.first;
      }
    }

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
              if (hasChapters) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) => ChapterListing(widget.fileDir),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) => MangaDetail(
                      widget.fileDir,
                      widget.fileDir.split('/').last,
                      '', // Empty chapter name for root-level manga
                    ),
                  ),
                );
              }
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
