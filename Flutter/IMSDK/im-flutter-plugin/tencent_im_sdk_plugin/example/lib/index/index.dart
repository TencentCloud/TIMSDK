// ignore_for_file: avoid_print


import 'package:example/callbacks/callbacks.dart';
import 'package:example/config/config.dart';
import 'package:example/index/exampleList.dart';
import 'package:example/setting/userSetting.dart';
import 'package:flutter/material.dart';
import 'package:gradient_ui_widgets/gradient_ui_widgets.dart' as button;

class Index extends StatelessWidget {
  const Index({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const IndexPage();
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage>  {
  @override
  void initState() {
    super.initState();

  }


  @override
  void dispose() {
    super.dispose();
  }

  openSettingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSetting(),
      ),
    );
  }

  openCallback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Callbacks(),
      ),
    );
  }

  final Gradient g1 = const LinearGradient(
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              openSettingPage();
            },
          )
        ],
        title: const Text(Config.appName),
      ),
      body: const ExampleList(),
      floatingActionButton: button.GradientFloatingActionButton(
        onPressed: () {
          openCallback();
        },
        child: const Icon(Icons.info_outline),
        shape: const StadiumBorder(),
        gradient: g1,
      ),
    );
  }
}
