import 'package:docman/docman.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/model/simple_file.dart';
import 'package:manga_reader/screens/manga_detail.dart';

class Chapter extends StatefulWidget {
  final SimpleFile file;
  final String mangaName;
  const Chapter(this.file,this.mangaName, {super.key});

  @override
  State<StatefulWidget> createState() {
   return _ChapterState();
  }
}

class _ChapterState extends State<Chapter>{

  bool clicked=false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          clicked=true;
        });
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => MangaDetail(DocumentFile.fromUri(widget.file.uri).then((z)=>z!.listDocuments()),widget.mangaName,widget.file.name.split(' ').last),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: clicked?Theme.of(context).colorScheme.secondaryFixedDim:Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Colors.black,
      ),child: FittedBox(
      fit: BoxFit.scaleDown, // 如果文字短，保持原样；如果长，则缩放
      child: Text(widget.file.name.split(' ').last),
    ),
    );
  }

}

