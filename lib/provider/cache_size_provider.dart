import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheSizeNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = SharedPreferencesAsync();
    return await prefs.getInt(AppUtils.cacheSize) ?? 100;
  }

  Future<void> setCacheSize(int size) async {
    state = AsyncData(size);
    final prefs = SharedPreferencesAsync();
    await prefs.setInt(AppUtils.cacheSize, size);
  }
}

final cacheSizeProvider = AsyncNotifierProvider<CacheSizeNotifier, int>(
  CacheSizeNotifier.new,
);
