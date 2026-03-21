import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentChapterNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return '';
  }

  Future<void> deleteChapter(String path) async {
    state = AsyncLoading();
    String parentPath = Directory(path).parent.path;
    await Directory(path).delete(recursive: true);
    state = AsyncData(parentPath);
  }

  Future<void> setCurrentChapter(String path) async {
    state = AsyncData(path);
  }
}

final currentChapterProvider =
    AsyncNotifierProvider<CurrentChapterNotifier, String>(
      CurrentChapterNotifier.new,
    );
