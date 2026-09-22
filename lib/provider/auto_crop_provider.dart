import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoCropNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = SharedPreferencesAsync();
    return await prefs.getBool(AppUtils.autoCropKey) ?? false;
  }

  Future<void> setAutoCrop(bool value) async {
    state = AsyncData(value);
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(AppUtils.autoCropKey, value);
  }
}

final autoCropProvider = AsyncNotifierProvider<AutoCropNotifier, bool>(
  AutoCropNotifier.new,
);
