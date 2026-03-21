import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/cache_size_provider.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:zoom_view/zoom_view.dart';

import '../utils/loading.dart';

class MangaDetail extends ConsumerStatefulWidget {
  String dir;
  String mangaName;
  String chapterName;
  final String parentPath;

  MangaDetail(
    this.dir,
    this.mangaName,
    this.chapterName,
    this.parentPath, {
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MangaDetailState();
  }
}

class _MangaDetailState extends ConsumerState<MangaDetail> {
  final int _currentPage = 1;
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final cacheSizeAsyncValue = ref.watch(cacheSizeProvider);

    return cacheSizeAsyncValue.when(
      // 只有第一次从 SharedPrefs 读取时会显示这个
      loading: () => const Loading(),
      // 读取失败的处理
      error: (err, stack) => Text('Error: $err'),
      // 一旦有了值（或者是之后的同步更新），都会走这里
      data: (cacheSize) => _buildMangaDetailScreen(cacheSize),
    );
  }

  Widget _buildMangaDetailScreen(int cacheSize) {
    final mangaImgList = Directory(widget.dir).listSync();
    mangaImgList.sort((a, b) {
      return Comparable.compare(a.path, b.path);
    });
    mangaImgList.removeWhere(
      (f) => !AppUtils.imgExtensions.contains(f.path.split('.').last),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.mangaName}-${widget.chapterName}',
          style: const TextStyle(fontSize: 14),
          maxLines: 3,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          ZoomListView(
            child: ListView.builder(
              controller: controller,
              cacheExtent: MediaQuery.of(context).size.height * cacheSize,
              itemCount: mangaImgList.length + 1,
              itemBuilder: (ctx, i) {
                if (i == mangaImgList.length) {
                  return SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text("End, Click to next chapter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        // int i = widget.allChapter!.indexWhere((ele) {
                        //   return ele.name!.contains(widget.chapterName);
                        // });
                        //
                        // if (i != -1 &&
                        //     i != widget.allChapter!.length - 1 &&
                        //     i < widget.allChapter!.length) {
                        //   confirm(ctx, content: Text('要去下一章节吗？')).then((value) {
                        //     if (value) {
                        //       setState(() {
                        //         widget.docs = DocumentFile.fromUri(
                        //           widget.allChapter!.elementAt(i + 1).uri!,
                        //         ).then((z) => z!.listDocuments());
                        //         List<String> cName = widget.allChapter!
                        //             .elementAt(i + 1)
                        //             .name!
                        //             .split(' ');
                        //         widget.chapterName = cName.length > 1
                        //             ? cName.elementAt(1)
                        //             : cName.elementAt(0);
                        //       });
                        //     }
                        //   });
                        // }
                      },
                    ),
                  );
                }
                return Image.file(File(mangaImgList[i].path));
              },
            ),
          ),
          _buildPageIndexIndicator(mangaImgList.length),
        ],
      ),
    );
  }

  // 构建固定在右下角的页面索引指示器
  /// TODO: havent done got issue!
  Widget _buildPageIndexIndicator(int totalPages) {
    // Positioned Widget 是 Stack 的专属子 Widget，用于定位
    return Positioned(
      // bottom: 16.0 和 right: 16.0 定义了它距离 Stack 底部和右侧的距离
      bottom: 16.0,
      right: 16.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        // 添加一个半透明的背景，让文字更易读
        decoration: BoxDecoration(
          color: Colors.black54, // 半透明黑色
          borderRadius: BorderRadius.circular(20.0), // 圆角
        ),
        child: Text(
          // 显示当前的页码 (从 1 开始) 和总页数
          '$_currentPage / $totalPages',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
