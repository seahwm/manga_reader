import 'package:flutter/material.dart';
import 'package:manga_reader/boc/manga_boc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AppUtils {
  AppUtils._();

  static const dirKey = 'manga_directory';

  static const dbName = 'manga.db';

  static Database? db;

  /// Initialize the app. Need to be called before trying to access the directory
  static Future<String> getSaveDirectory() {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.getString(dirKey) ?? '',
    );
  }

  static List<String> imgExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];

  static Future<void> initDb() async {
    var databasesPath = await getDatabasesPath();
    if(db==null){
      db = await openDatabase(dbName);
    }
    await mangaBoc.init();
  }

  /// Utils method to show the snack bar
  static void showSnackBar(
    BuildContext context,
    String? msg, {
    Duration duration = Durations.extralong1,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    msg ??= '';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), duration: duration));
  }

  /// Utils method to show the alert dialog
  static void showAlertDialog(
    BuildContext context,
    String? msg, {
    String title = 'Alert',
  }) {
    if ((msg == null || msg.isEmpty) && title == 'Alert') return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(msg!)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

final mangaBoc = MangaBoc();
