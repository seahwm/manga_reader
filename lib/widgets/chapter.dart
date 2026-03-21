import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/current_chapter_provider.dart';

import '../screens/manga_detail.dart';

class Chapter extends ConsumerStatefulWidget {
  final String dir;
  final String mangaName;

  const Chapter(this.dir, this.mangaName, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ChapterState();
  }
}

class _ChapterState extends ConsumerState<Chapter> {
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onLongPress: () async {
        if (await confirm(
          context,
          content: Text(
            'Are you sure want to delete ${widget.dir.split('/').last.split(' ').last}？',
          ),
        )) {
          ref.read(currentChapterProvider.notifier).deleteChapter(widget.dir);
        }
      },
      onPressed: () async {
        setState(() {
          clicked = true;
        });
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => MangaDetail(
              widget.dir,
              widget.mangaName,
              widget.dir.split('/').last.split(' ').last,
              Directory(widget.dir).parent.path,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: clicked
            ? Theme.of(context).colorScheme.secondaryFixedDim
            : Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Colors.black,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown, // 如果文字短，保持原样；如果长，则缩放
        child: Text(widget.dir.split('/').last.split(' ').last),
      ),
    );
  }
}
