// ignore_for_file: avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/utils/offline_push_config.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

bool isInitScreenUtils = false;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var subscription;
  final Connectivity _connectivity = Connectivity();
  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  Widget currentApp = Center(
    child: Text(imt("正在加载...")),
  );

  directToLogin() {
    setState(() {
      currentApp = const LoginPage();
    });
  }

  directToHomePage() {
    setState(() {
      currentApp = const HomePage();
    });
  }

  onKickedOffline() async {
    try {
      directToLogin();
    } catch (err) {}
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  initIMSDKAndAddIMListeners() async {
    final isInitSuccess = await _coreInstance.init(
      sdkAppID: IMDemoConfig.sdkappid,
      loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
      listener: V2TimSDKListener(
        onConnectFailed: (code, error) {},
        onConnectSuccess: () {
          Utils.log(imt("即时通信服务连接成功"));
        },
        onConnecting: () {},
        onKickedOffline: () {
          onKickedOffline();
        },
        onSelfInfoUpdated: (info) {
          print(imt("信息已变更"));
          // onSelfInfoUpdated(info);
        },
        onUserSigExpired: () {
          // userSig过期，相当于踢下线
          onKickedOffline();
        },
      ),
    );
    if (isInitSuccess == null || !isInitSuccess) {
      Utils.toast(imt("即时通信 SDK初始化失败"));
    } else {}
    // setState(() {
    //   hasInit = true;
    // });
  }

  initApp() {
    // 初始化IM SDK
    initIMSDKAndAddIMListeners();

    directToLogin();
  }

  initScreenUtils() {
    if (isInitScreenUtils) return;
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
      // 设计稿尺寸：px
      designSize: const Size(750, 1624),
      context: context,
      minTextAdapt: true,
    );
    isInitScreenUtils = true;
  }

  void handleClickNotification(Map<String, dynamic> msg) {
    // TODO跳转页面，拉起音视频通话等
    print(msg);
  }

  @override
  void initState() {
    super.initState();
    subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        Utils.toast(imt("网络连接丢失"));
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return const NoConnectivityPage();
        //     },
        //   ),
        // );
      }
    });
    OfflinePush.init(handleClickNotification);
    initApp();
  }

  @override
  dispose() {
    super.dispose();
    // subscription.cancle();
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtils();
    return currentApp;
  }
}
