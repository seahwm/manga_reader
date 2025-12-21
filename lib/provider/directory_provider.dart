import 'package:docman/docman.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FldToListen {
  String? dir;
  String? idx;

  FldToListen({this.dir, this.idx});
}

class DirectoryNotifier extends StateNotifier<FldToListen?> {
  DirectoryNotifier() : super(null);

  void updateDirectory(String? newDir) {
    if (newDir == null || newDir.isEmpty) {
      return;
    }
    state = FldToListen(dir: newDir, idx: state?.idx);
  }

  void updateIdx(String? idx) {
    if (idx == null || idx.isEmpty) {
      return;
    }
    state = FldToListen(dir: state?.dir, idx: idx);
  }

  void pickDirectory() async {
    DocumentFile? dir = await DocMan.pick.directory();

    if (dir == null) {
      return;
    }
    state = FldToListen(dir: dir.uri, idx: state?.idx);
    await SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(AppUtils.dirKey, dir.uri),
    );
  }
}

final directoryProvider =
    StateNotifierProvider<DirectoryNotifier, FldToListen?>(
      (ref) => DirectoryNotifier(),
    );
