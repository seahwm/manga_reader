class Manga {
  static const String tableName = 'MANGA';
  static const String idCol = 'ID';
  static const String nameCol = 'NAME';
  static const String parentPathCol = 'PARENT_PATH';
  static const String uriCol = 'URI';
  static const String indexUriCol = 'INDEX_URI';
  static const List<String> allCol = [
    idCol,
    nameCol,
    parentPathCol,
    uriCol,
    indexUriCol,
  ];

  int? id;
  String? name;
  String? parentPath;
  String? uri;
  String? indexUri;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      nameCol: name,
      parentPathCol: parentPath,
      uriCol: uri,
      indexUriCol: indexUri,
    };
    if (id != null) {
      map[idCol] = id;
    }
    return map;
  }

  Manga({this.id, this.name, this.parentPath, this.uri, this.indexUri});

  static fromMap(Map<String, Object?> map) {
    final id = map[idCol] as int?;
    final name = map[nameCol] as String?;
    final parentPath = map[parentPathCol] as String?;
    final uri = map[uriCol] as String?;
    final indexUri = map[indexUriCol] as String?;
    return Manga(
      id: id,
      name: name,
      parentPath: parentPath,
      uri: uri,
      indexUri: indexUri,
    );
  }
}
