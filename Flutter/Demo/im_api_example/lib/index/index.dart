import 'package:im_api_example/callbacks/callbacks.dart';
import 'package:im_api_example/config/config.dart';
import 'package:im_api_example/index/exampleList.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/setting/userSetting.dart';
import 'package:gradient_ui_widgets/gradient_ui_widgets.dart' as button;
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Index extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IndexPage();
  }
}

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("-didChangeAppLifecycleState-" + state.toString());
    // 这里要登录态度
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        TencentImSDKPlugin.v2TIMManager.getOfflinePushManager().doForeground();
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        TencentImSDKPlugin.v2TIMManager.getOfflinePushManager().doForeground();
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        TencentImSDKPlugin.v2TIMManager.getOfflinePushManager().doBackground(
              unreadCount: 0,
            );
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this); //销毁
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

  final Gradient g1 = LinearGradient(
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
          Container(
            child: IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                openSettingPage();
              },
            ),
          )
        ],
        title: Text(Config.appName),
      ),
      body: ExampleList(),
      floatingActionButton: button.GradientFloatingActionButton(
        onPressed: () {
          openCallback();
        },
        child: Icon(Icons.info_outline),
        shape: StadiumBorder(),
        gradient: g1,
      ),
    );
  }
}
