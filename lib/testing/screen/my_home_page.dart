import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/directory_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../provider/app_title_provider.dart';

class MyHomePageTest extends ConsumerStatefulWidget {
  const MyHomePageTest({super.key});

  @override
  ConsumerState<MyHomePageTest> createState() => _MyHomePageStateTest();
}

class _MyHomePageStateTest extends ConsumerState<MyHomePageTest> {
  @override
  Widget build(BuildContext context) {
    final title = ref.watch(appTitleProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(child: Text('This is Testing Screen')),
      floatingActionButton: FloatingActionButton(
        onPressed: onBtnClick,
        tooltip: 'Testing',
        child: const Icon(Icons.circle_outlined),
      ),
    );
  }

  void showDialog(String title,String msg){
      showAboutDialog(
        context: context,
        applicationName: title,
        children: [Text(msg)],
      );
  }


  void onBtnClick() async {
    // if(1==1){
    //   showAboutDialog(
    //     context: context,
    //     applicationName: "On Click",
    //     children: [Text('Hello World')],
    //   );
    // }

    final isGrandPermission = await Permission.manageExternalStorage.isGranted;
    if (!isGrandPermission) {
      Permission.manageExternalStorage.request();
    }else{
      // showDialog("Manage External Storage","Permission Granted");
      ref.read(directoryProvider.notifier).pickDirectory();
    }
  }
}
