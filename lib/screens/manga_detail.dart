import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/cache_size_provider.dart';
import 'package:manga_reader/provider/auto_crop_provider.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:manga_reader/widgets/auto_crop_image.dart';
import 'package:zoom_view/zoom_view.dart';

import '../utils/loading.dart';

class MangaDetail extends ConsumerStatefulWidget {
  String dir;
  String mangaName;
  String chapterName;

  MangaDetail(this.dir, this.mangaName, this.chapterName, {super.key});

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
    final autoCropAsyncValue = ref.watch(autoCropProvider);

    if (cacheSizeAsyncValue.isLoading || autoCropAsyncValue.isLoading) {
      return const Loading();
    }

    if (cacheSizeAsyncValue.hasError) return Text('Error: ${cacheSizeAsyncValue.error}');
    if (autoCropAsyncValue.hasError) return Text('Error: ${autoCropAsyncValue.error}');

    return _buildMangaDetailScreen(
      cacheSizeAsyncValue.value ?? 100,
      autoCropAsyncValue.value ?? false,
    );
  }

  Widget _buildMangaDetailScreen(int cacheSize, bool autoCrop) {
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
          widget.chapterName.isEmpty ? widget.mangaName : '${widget.mangaName}-${widget.chapterName}',
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
                        final allChapter = Directory(
                          widget.dir,
                        ).parent.listSync();
                        allChapter.sort((a, b) {
                          return Comparable.compare(a.path, b.path);
                        });
                        int i = allChapter.indexWhere(
                          (f) => f.path == widget.dir,
                        );
                        if (widget.chapterName.isNotEmpty && i != -1 && i != allChapter.length - 1) {
                          confirm(ctx, content: Text('Next Chapter？')).then((
                            value,
                          ) {
                            if (value) {
                              setState(() {
                                widget.dir = allChapter[i + 1].path;
                                widget.chapterName = widget.dir
                                    .split('/')
                                    .last
                                    .split(' ')
                                    .last;
                              });
                            }
                          });
                        }
                      },
                    ),
                  );
                }
                return AutoCropImage(
                  file: File(mangaImgList[i].path),
                  autoCrop: autoCrop,
                );
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
