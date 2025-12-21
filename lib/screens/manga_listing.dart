import 'package:docman/docman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/directory_provider.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:manga_reader/widgets/manga.dart';
import 'package:manga_reader/model/manga.dart' as mangaTable;

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
    FldToListen? fld=ref.watch(directoryProvider);
    String? dir = fld?.dir;
    if (dir == null || dir.isEmpty) {
      return const Text("No data");
    }
    return FutureBuilder<List<DocumentFile>>(
      future: mangaBoc.findByParentPath(dir).then((manga) {
        if (manga.isEmpty) {
          return DocumentFile.fromUri(
            dir,
          ).then((doc) => doc?.listDocuments() ?? []);
        } else {
          return mangaBoc.cnvMangasToDocumentFiles(manga);
        }
      }),
      builder:
          (BuildContext context, AsyncSnapshot<List<DocumentFile>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 如果还在加载，显示一个加载指示器
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // 如果出现错误，显示错误信息
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // 如果数据加载成功，构建ListView
              final List<DocumentFile> items = snapshot.data!;
              mangaBoc.findByParentPath(dir).then((mangas) {
                final nameSet = Set();
                for (final m in mangas) {
                  nameSet.add(m.name);
                }
                for (final i in items) {
                  if (!nameSet.contains(i.name)) {
                    final m = mangaTable.Manga(
                      name: i.name,
                      parentPath: dir,
                      uri: i.uri,
                    );
                    mangaBoc.add(m);
                  }
                }
              });

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 10,
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Manga(items[index]);
                },
              );

              // return ListView.builder(
              //   itemCount: items.length,
              //   itemBuilder: (context, index) {
              //     return ListTile(title: Text(items[index].path));
              //   },
              // );
            } else {
              // 其他情况（例如没有数据），可以显示一个空列表消息
              return const Text('No data available');
            }
          },
    );
  }
}
