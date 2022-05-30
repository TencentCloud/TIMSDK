// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, empty_catches

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tim_ui_kit/ui/constants/emoji.dart';
import 'package:tim_ui_kit/ui/widgets/emoji.dart';
import 'package:tim_ui_kit_sticker_plugin/utils/tim_ui_kit_sticker_data.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/utils/push/channel/channel_push.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/custom_sticker_package.dart';
import 'package:timuikit/utils/constant.dart';
import 'package:provider/provider.dart';



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
  final ConversationService _conversationService = serviceLocator<ConversationService>();

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
      // 此处可指定显示语言，不传该字段使用系统语言
      // language: LanguageEnum.zh,
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
    setCustomSticker();
  }

  void handleClickNotification(Map<String, dynamic> msg) async {
    String ext = msg['ext'] ?? "";
    Map<String, dynamic> extMsp = jsonDecode(ext);
    String convId = extMsp["conversationID"] ?? "";
    V2TimConversation? targetConversation = await _conversationService.getConversation(conversationID: convId);
    if(targetConversation != null){
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              selectedConversation: targetConversation,
            ),
          ));
    }
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
    // OfflinePush.init(handleClickNotification);
    ChannelPush.init(handleClickNotification);
    initApp();
  }

  @override
  dispose() {
    super.dispose();
    // subscription.cancle();
  }

  setCustomSticker() async {
    // 添加自定义表情包
    List<CustomStickerPackage> customStickerPackageList = [];
    final defEmojiList = emojiData.asMap().keys.map((emojiIndex) {
      final emo = Emoji.fromJson(emojiData[emojiIndex]);
      return CustomSticker(
          index: emojiIndex, name: emo.name, unicode: emo.unicode);
    }).toList();
    customStickerPackageList.add(CustomStickerPackage(
        name: "defaultEmoji",
        stickerList: defEmojiList,
        menuItem: defEmojiList[0]));
    customStickerPackageList.addAll(Const.emojiList.map((customEmojiPackage) {
      return CustomStickerPackage(
          name: customEmojiPackage.name,
          baseUrl: "assets/custom_face_resource/${customEmojiPackage.name}",
          stickerList: customEmojiPackage.list
              .asMap()
              .keys
              .map((idx) =>
                  CustomSticker(index: idx, name: customEmojiPackage.list[idx]))
              .toList(),
          menuItem: CustomSticker(
            index: 0,
            name: customEmojiPackage.icon,
          ));
    }).toList());
    Provider.of<CustomStickerPackageData>(context, listen: false)
        .customStickerPackageList = customStickerPackageList;
  }

  @override
  Widget build(BuildContext context) {
    initScreenUtils();
    return currentApp;
  }
}
