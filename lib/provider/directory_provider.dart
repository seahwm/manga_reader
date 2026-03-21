import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = SharedPreferencesAsync();
    return await prefs.getString(AppUtils.dirKey) ?? '';
  }

  Future<void> deleteManga(String path) async {
    final crrVal = state.value;
    if (crrVal == null) {
      return Future.value();
    }
    state = AsyncLoading();
    await Directory(path).delete(recursive: true);
    state = AsyncData(crrVal);
  }

  Future<void> pickDirectory() async {
    final isGrandPermission = await Permission.manageExternalStorage.isGranted;
    if (!isGrandPermission) {
      await Permission.manageExternalStorage.request();
    }

    final dir = await FilePicker.platform.getDirectoryPath();
    state = AsyncData(dir ?? '');
    final prefs = SharedPreferencesAsync();
    await prefs.setString(AppUtils.dirKey, dir ?? '');
  }
}

final directoryProvider = AsyncNotifierProvider<DirectoryNotifier, String>(
  DirectoryNotifier.new,
);
