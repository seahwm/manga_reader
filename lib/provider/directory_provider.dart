import 'package:docman/docman.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryNotifier extends StateNotifier<String?> {
  DirectoryNotifier() : super(null);

  void updateDirectory(String? newDir) {
    if (newDir == null || newDir.isEmpty) {
      return;
    }
    state = newDir;
  }

  void pickDirectory() async {
    DocumentFile? dir = await DocMan.pick.directory();

    if (dir == null) {
      return;
    }
    state = dir.uri;
    await SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(AppUtils.dirKey, dir.uri),
    );
  }
}

final directoryProvider = StateNotifierProvider<DirectoryNotifier, String?>(
  (ref) => DirectoryNotifier(),
);
