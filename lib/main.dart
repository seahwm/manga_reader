import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/app_title_provider.dart';
import 'package:manga_reader/provider/directory_provider.dart';
import 'package:manga_reader/screens/setting.dart';
import 'package:manga_reader/screens/manga_listing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final dir = await AppUtils.getSaveDirectory();
  // pagesToCache=await AppUtils.getCacheSize();
  // final dirNotifier = DirectoryNotifier();
  // dirNotifier.updateDirectory(dir);
  // await AppUtils.initDb();
  runApp(
    ProviderScope(
      // overrides: [directoryProvider.overrideWith((ref) => dirNotifier)],
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
            icon:Icon(Icons.settings),
            onPressed: () async{
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },

          ),
        ],
      ),
      body: const MangaListing(),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.read(directoryProvider.notifier).pickDirectory,
        tooltip: 'Select Manga Directory',
        child: const Icon(Icons.folder),
      ),
    );
  }
}
