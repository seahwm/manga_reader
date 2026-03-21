import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/directory_provider.dart';
import 'package:manga_reader/utils/loading.dart';
import 'package:manga_reader/widgets/manga.dart';

class MangaListing extends ConsumerStatefulWidget {
  const MangaListing({super.key});

  @override
  ConsumerState<MangaListing> createState() {
    return _MangaListingState();
  }
}

class _MangaListingState extends ConsumerState<MangaListing> {
  @override
  Widget build(BuildContext context) {
    final path = ref.watch(directoryProvider);

    return path.when(
      // 只有第一次从 SharedPrefs 读取时会显示这个
      loading: () => const Loading(),
      // 读取失败的处理
      error: (err, stack) => Text('Error: $err'),
      // 一旦有了值（或者是之后的同步更新），都会走这里
      data: (path) =>
          path.isEmpty ? Center(child: Text('No data')) : ListingScreen(path),
    );
  }

  Widget ListingScreen(String path) {
    final dir = Directory(path);
    final mangaList = dir.listSync();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 25,
        childAspectRatio: 0.7,
        mainAxisSpacing: 10,
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      itemCount: mangaList.length,
      itemBuilder: (context, index) {
        return Manga(mangaList[index].path);
      },
    );
  }
}
