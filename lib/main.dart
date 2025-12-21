import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/app_title_provider.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:manga_reader/screens/manga_listing.dart';

import 'provider/directory_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await AppUtils.getSaveDirectory();
  final dirNotifier = DirectoryNotifier();
  dirNotifier.updateDirectory(dir);
  await AppUtils.initDb();
  runApp(
    ProviderScope(
      overrides: [directoryProvider.overrideWith((ref) => dirNotifier)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xxxz漫画阅读器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

// class MyHomePageTest extends ConsumerStatefulWidget {
//   const MyHomePageTest({super.key});
//
//   @override
//   ConsumerState<MyHomePageTest> createState() => _MyHomePageStateTest();
// }
//
// class _MyHomePageStateTest extends ConsumerState<MyHomePageTest> {
//   @override
//   void initState()  {
//      AppUtils.initDb();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final title = ref.watch(appTitleProvider);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(title),
//       ),
//       body: Center(child: Text('Hello World')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: onBtnClick,
//         tooltip: 'Select Manga Directory',
//         child: const Icon(Icons.folder),
//       ),
//     );
//   }
//
//   onBtnClick() async {
//     final x=await mangaBoc.init();
//     final m = Manga(uri: 'aa', parentPath: 'dd', name: 'sss');
//     mangaBoc.add(m);
//   }
// }

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final title = ref.watch(appTitleProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          IconButton(
            icon:Icon(Icons.cleaning_services_outlined),
            onPressed: () async{
              if (await confirm(context,content:Text('Are You Sure want to delete all data in db?'))) {
              return debugPrint('pressedOK');
              mangaBoc.deleteAll();

              }else{
              return debugPrint('pressedCancel');

              }
            },

          ),
        ],
      ),
      body: MangaListing(),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.read(directoryProvider.notifier).pickDirectory,
        tooltip: 'Select Manga Directory',
        child: const Icon(Icons.folder),
      ),
    );
  }
}
