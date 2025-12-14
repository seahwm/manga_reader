import 'package:docman/docman.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/widgets/chapter.dart';

class ChapterListing extends StatelessWidget {
  final DocumentFile dir;

  const ChapterListing(this.dir, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dir.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<DocumentFile>>(
        future: dir.listDocuments(),
        builder:
            (BuildContext context, AsyncSnapshot<List<DocumentFile>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 如果还在加载，显示一个加载指示器
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // 如果出现错误，显示错误信息
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final List<DocumentFile> items = snapshot.data!;
                items.removeWhere((doc) {
                  return doc.name.contains("index");
                });
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 25,
                    childAspectRatio: 20 / 6,
                    mainAxisSpacing: 10,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Chapter(items[index],dir.name);
                  },
                );
              } else {
                // 其他情况（例如没有数据），可以显示一个空列表消息
                return const Text('No data available');
              }
            },
      ),
    );
  }
}
