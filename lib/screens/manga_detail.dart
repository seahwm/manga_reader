import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:docman/docman.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/model/manga.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:zoom_view/zoom_view.dart';

class MangaDetail extends StatefulWidget {
  Future<List<DocumentFile>> docs;
  String mangaName;
  String chapterName;
  List<Manga>? allChapter;
  final String parentUri;

  MangaDetail(
    this.docs,
    this.mangaName,
    this.chapterName,
    this.parentUri, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _MangaDetailState();
  }
}

class _MangaDetailState extends State<MangaDetail> {
  final int _currentPage = 1;
  ScrollController controller = ScrollController();
  DateTime? _lastTriggerTime;
  @override
  void initState() {
    mangaBoc.findByParentPath(widget.parentUri).then((value) {
      AppUtils.sort(value);
      widget.allChapter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.mangaName}-${widget.chapterName}',
          style: const TextStyle(fontSize: 14),
          maxLines: 3,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<DocumentFile>>(
        future: widget.docs,
        builder: (docsCtx, docsSnapshot) {
          if (docsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading Documents'));
          } else if (docsSnapshot.hasError) {
            return Text('Error: ${docsSnapshot.error}');
          } else if (docsSnapshot.hasData) {
            docsSnapshot.data!.sort((a, b) {
              return Comparable.compare(a.name, b.name);
            });
            List<DocumentFile> mangaImgs = docsSnapshot.data!;
            mangaImgs.removeWhere(
              (f) => !AppUtils.imgExtensions.contains(f.name.split('.').last),
            );
            return Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  child: ZoomListView(
                    child: ListView.builder(
                      controller: controller,
                      cacheExtent: MediaQuery.of(context).size.height * 30,
                      itemCount: mangaImgs.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == mangaImgs.length) {
                          return Center(child: Text("End"));
                        }
                        return FutureBuilder(
                          future: mangaImgs[i].read(),
                          builder: (ctx, sanpshot) {
                            if (sanpshot.hasData) {
                              return Image.memory(sanpshot.data!);
                            } else {
                              return Text('${mangaImgs[i].name}No data');
                            }
                          },
                        );
                      },
                    ),
                  ),
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      // 1. 确保是直接子组件发出的通知，避免嵌套干扰 (Depth Check)
                      // if (notification.depth != 0) return false;

                      // 2. 获取滚动的度量信息 (Scroll Metrics)
                      final metrics = notification.metrics;

                      // 2. 检查是否已经到达或超过底部 (At Bottom)
                      bool isAtBottom = metrics.pixels >= metrics.maxScrollExtent;

                      // 3. 检查滑动方向 (Scroll Direction)
                      // scrollDelta > 0 表示用户在向上划动手指，列表向内容下方滚动（向下划）
                      bool isScrollingDown = (notification.scrollDelta ?? 0) > 0;
                      // 3. 判断当前滚动位置是否接近或等于最大滚动范围
                      // pixels: 当前位置, maxScrollExtent: 最大可滚动范围
                      if (isAtBottom&& isScrollingDown) {
                        final now = DateTime.now();
                        if (_lastTriggerTime != null &&
                            now.difference(_lastTriggerTime!).inMilliseconds < 500) {
                          return false;
                        }
                        _lastTriggerTime = now;
                        print("检测到触底 (Approaching bottom)!");
                        // 在这里执行加载更多的逻辑
                        int i = widget.allChapter!.indexWhere((ele) {
                          return ele.name!.contains(widget.chapterName);
                        });

                        if (i != -1 &&
                            i != widget.allChapter!.length - 1 &&
                            i < widget.allChapter!.length) {
                          confirm(context, content: Text('要去下一章节吗？')).then((
                            value,
                          ) {
                            if (value) {
                              setState(() {
                                widget.docs = DocumentFile.fromUri(
                                  widget.allChapter!.elementAt(i + 1).uri!,
                                ).then((z) => z!.listDocuments());
                                List<String> cName = widget.allChapter!
                                    .elementAt(i + 1)
                                    .name!
                                    .split(' ');
                                widget.chapterName = cName.length > 1
                                    ? cName.elementAt(1)
                                    : cName.elementAt(0);
                              });
                            }
                          });
                        }
                      }
                    }
                    return false;
                  },
                ),
                _buildPageIndexIndicator(mangaImgs.length),
              ],
            );
          } else {
            return Text('Out of expectation');
          }
        },
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
