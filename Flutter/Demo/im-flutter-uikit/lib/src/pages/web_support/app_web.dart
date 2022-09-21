// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, empty_catches

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/data_services/core/tim_uikit_config.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tim_ui_kit/ui/constants/emoji.dart';
import 'package:tim_ui_kit/ui/widgets/emoji.dart';
import 'package:tim_ui_kit_sticker_plugin/utils/tim_ui_kit_sticker_data.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/launch_page.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/web_support/web_login.dart';
import 'package:timuikit/src/provider/local_setting.dart';
import 'package:timuikit/src/provider/login_user_Info.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/routes.dart';
import 'package:timuikit/utils/smsLogin.dart';
import 'package:timuikit/utils/theme.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/custom_sticker_package.dart';
import 'package:timuikit/utils/constant.dart';
import 'package:provider/provider.dart';

bool isInitScreenUtils = false;

class WebApp extends StatefulWidget {
  const WebApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<WebApp> with WidgetsBindingObserver {
  var subscription;
  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();

  directToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const WebLoginPage(),
          );
        },
      ),
      ModalRoute.withName('/'),
    );
  }

  directToHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const HomePage(),
          );
        },
      ),
      ModalRoute.withName('/'),
    );
  }

  onKickedOffline() async {
    try {
      directToLogin();
    } catch (err) {}
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const WebLoginPage()),
      ModalRoute.withName('/'),
    );
  }

  getLoginUserInfo() async {
    final res = await _sdkInstance.getLoginUser();
    if (res.code == 0) {
      final result = await _sdkInstance.getUsersInfo(userIDList: [res.data!]);

      if (result.code == 0) {
        Provider.of<LoginUserInfo>(context, listen: false)
            .setLoginUserInfo(result.data![0]);
      }
    }
  }

  initIMSDKAndAddIMListeners() async {
    final LocalSetting localSetting = Provider.of<LocalSetting>(context, listen: false);
    final isInitSuccess = await _coreInstance.init(
      // You can specify the language here,
      // not providing this field means using the system language.
      // language: LanguageEnum.zh,
      onWebLoginSuccess: getLoginUserInfo,
      config: TIMUIKitConfig(
        // This status is default to true,
        // its unnecessary to specify this if you tend to use online status.
        isShowOnlineStatus: localSetting.isShowOnlineStatus,
      ),
      onTUIKitCallbackListener: (TIMCallback callbackValue) {
        switch (callbackValue.type) {
          case TIMCallbackType.INFO:
          // Shows the recommend text for info callback directly
            Utils.toast(callbackValue.infoRecommendText!);
            break;

          case TIMCallbackType.API_ERROR:
          //Prints the API error to console, and shows the error message.
            print(
                "Error from TUIKit: ${callbackValue.errorMsg}, Code: ${callbackValue.errorCode}");
            if (callbackValue.errorCode == 10004 &&
                callbackValue.errorMsg!.contains("not support @all")) {
              Utils.toast(imt("当前群组不支持@全体成员"));
            } else if (callbackValue.errorCode == 80001 &&
                callbackValue.errorMsg!.contains("not support @all")) {
              Utils.toast(imt("发言中有非法语句"));
            } else {
              Utils.toast(
                  callbackValue.errorMsg ?? callbackValue.errorCode.toString());
            }
            break;

          case TIMCallbackType.FLUTTER_ERROR:
          default:
          // prints the stack trace to console or shows the catch error
            if (callbackValue.catchError != null) {
              Utils.toast(callbackValue.catchError.toString());
            } else {
              print(callbackValue.stackTrace);
            }
        }
      },
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
          Provider.of<LoginUserInfo>(context, listen: false)
              .setLoginUserInfo(info);
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

    Future.delayed(const Duration(seconds: 1), () {
      checkLogin();
      // 修改自定义表情的执行时机
      setCustomSticker();
    });
  }

  setTheme(String themeTypeString) {
    ThemeType themeType = DefTheme.themeTypeFromString(themeTypeString);
    Provider.of<DefaultThemeData>(context, listen: false).currentThemeType =
        themeType;
    Provider.of<DefaultThemeData>(context, listen: false).theme =
    DefTheme.defaultTheme[themeType]!;
    _coreInstance.setTheme(theme: DefTheme.defaultTheme[themeType]!);
  }

  removeLocalSetting() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    prefs.remove("smsLoginToken");
    prefs.remove("smsLoginPhone");
    prefs.remove("smsLoginUserID");
    prefs.remove("channelListMain");
    prefs.remove("discussListMain");
    prefs.remove("themeType");
  }

  checkLogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("smsLoginToken");
    String? phone = prefs.getString("smsLoginPhone");
    String? userId = prefs.getString("smsLoginUserID");
    String themeTypeString = prefs.getString("themeType") ?? "";
    setTheme(themeTypeString);
    setCustomSticker();
    if (token != null && phone != null && userId != null) {
      Map<String, dynamic> response = await SmsLogin.smsTokenLogin(
        userId: userId,
        token: token,
      );
      int errorCode = response['errorCode'];
      String errorMessage = response['errorMessage'];

      if (errorCode == 0) {
        Map<String, dynamic> datas = response['data'];
        String userId = datas['userId'];
        String userSig = datas['sdkUserSig'];
        print(_coreInstance.loginUserInfo);
        await initIMSDKAndAddIMListeners();
        V2TimCallback data =
        await _coreInstance.login(userID: userId, userSig: userSig);

        if (data.code != 0) {
          final option8 = data.desc;
          Utils.toast(
              imt_para("登录失败 {{option8}}", "登录失败 $option8")(option8: option8));
          removeLocalSetting();
          directToLogin();
          return;
        }
        directToHomePage();
      } else {
        Utils.toast(errorMessage);
        directToLogin();
      }
    } else {
      directToLogin();
    }
  }

  initScreenUtils() {
    if (isInitScreenUtils) return;
    ScreenUtil.init(
      context,
      designSize: const Size(750, 1624),
      minTextAdapt: true,
    );
    isInitScreenUtils = true;
    
  }

  initRouteListener() {
    final routes = Routes();
    routes.addListener(() {
      final pageType = routes.pageType;
      if (pageType == "loginPage") {
        directToLogin();
      }

      if (pageType == "homePage") {
        directToHomePage();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initRouteListener();
    WidgetsBinding.instance?.addObserver(this);
    initApp();
  }

  @override
  dispose() {
    super.dispose();
    Routes().dispose();
    WidgetsBinding.instance?.removeObserver(this);
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
    return const LaunchPage();
  }
}

