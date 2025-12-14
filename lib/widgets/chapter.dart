import 'package:docman/docman.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/screens/manga_detail.dart';

class Chapter extends StatefulWidget {
  final DocumentFile file;
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
            builder: (context) => MangaDetail(widget.file.listDocuments(),widget.mangaName,widget.file.name.split(' ').last),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: clicked?Theme.of(context).colorScheme.secondaryFixedDim:Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Colors.black,
      ),
      child: Text(widget.file.name.split(' ').last),
    );
  }

}

