import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/current_chapter_provider.dart';
import 'package:manga_reader/widgets/chapter.dart';

import '../utils/loading.dart';

class ChapterListing extends ConsumerStatefulWidget {
  final String path;

  ChapterListing(this.path, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ChapterListingState();
  }
}

class _ChapterListingState extends ConsumerState<ChapterListing> {
  @override
  Widget build(BuildContext context) {
    final chapProvider = ref.watch(currentChapterProvider);
    return chapProvider.when(
      //path.split('/').last
      // 只有第一次从 SharedPrefs 读取时会显示这个
      loading: () => _buildChapterListing(const Loading(),'Loading'),
      // 读取失败的处理
      error: (err, stack) =>
          _buildChapterListing(Text(err.toString()), 'Error'),
      // 一旦有了值（或者是之后的同步更新），都会走这里
      data: (path) {
        if (path.isEmpty) {
          Future.microtask(() {
            ref
                .read(currentChapterProvider.notifier)
                .setCurrentChapter(widget.path);
          });
          return _buildChapterListing(const Loading(), 'Loading');
        }
        return _buildChapterListing(
          _ChapterListing(path),
          path.split('/').last,
        );
      },
    );
  }

  Widget _ChapterListing(String path) {
    final mangaDir = Directory(path);
    final chapterList = mangaDir.listSync();
    // remove cover page image, and only list the chapter folder.
    chapterList.removeWhere((f) => !Directory(f.path).existsSync());
    chapterList.sort((a, b) {
      return Comparable.compare(a.path, b.path);
    });
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 25,
        childAspectRatio: 20 / 6,
        mainAxisSpacing: 10,
      ),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      itemCount: chapterList.length,
      itemBuilder: (context, index) {
        return Chapter(chapterList[index].path, path.split('/').last);
      },
    );
  }

  Widget _buildChapterListing(Widget w, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: w,
    );
  }
}
