import 'package:docman/docman.dart';
import 'package:manga_reader/model/manga.dart';
import 'package:manga_reader/model/simple_file.dart';
import 'package:manga_reader/utils/app_utils.dart';

class MangaBoc {
  init() {
    AppUtils.db!.execute('''
  CREATE TABLE IF NOT EXISTS MANGA (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  NAME TEXT,
  PARENT_PATH TEXT,
  URI TEXT,
  INDEX_URI TEXT
);
''');
  }

  Future<Manga> add(Manga manga) async {
    manga.id = await AppUtils.db!.insert(Manga.tableName, manga.toMap());
    return manga;
  }

  Future<Manga> update(Manga manga) async {
    if (manga.id != null) {
      AppUtils.db!.update(
        Manga.tableName,
        manga.toMap(),
        where: '${Manga.idCol} = ?',
        whereArgs: [manga.id],
      );
    }
    return manga;
  }

  Future<Manga?> findByUri(String uri) async {
    return AppUtils.db!
        .query(
          Manga.tableName,
          columns: Manga.allCol,
          where: '${Manga.uriCol} = ?',
          whereArgs: [uri],
        )
        .then((map) {
          if (map.isNotEmpty) {
            return Manga.fromMap(map.first);
          } else {
            return null;
          }
        });
  }

  Future<List<DocumentFile>> cnvMangasToDocumentFiles(List<Manga> mangas) {
    final rsl = <Future<DocumentFile?>>[];
    for (final m in mangas) {
      rsl.add(DocumentFile.fromUri(m.uri!));
    }
    return Future.wait(rsl).then((val) {
      return val.whereType<DocumentFile>().toList();
    });
  }

  Future<List<SimpleFile>> cnvMangasToSimpleFiles(List<Manga> mangas) {
    final rsl = <SimpleFile>[];
    for (final m in mangas) {
      rsl.add(SimpleFile(m.name!, m.uri!,m.parentPath!));
    }
    return Future.value(rsl);
  }

  Future<List<Manga>> findByParentPath(String parentPath) async {
    return AppUtils.db!
        .query(
          Manga.tableName,
          columns: Manga.allCol,
          where: '${Manga.parentPathCol} = ?',
          whereArgs: [parentPath],
        )
        .then((maps) {
          final List<Manga> rsl = [];
          for (final map in maps) {
            rsl.add(Manga.fromMap(map));
          }
          return rsl;
        });
  }

  Future<void> deleteAll() async {
    await AppUtils.db!.delete(Manga.tableName);
  }

  Future<int> delete(int id) async {
    return await AppUtils.db!.delete(
      Manga.tableName,
      where: '${Manga.idCol} = ?',
      whereArgs: [id],
    );
  }
}
