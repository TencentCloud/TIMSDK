import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tim_ui_kit/ui/widgets/emoji.dart';
import 'package:tim_ui_kit_sticker_plugin/tim_ui_kit_sticker_plugin.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/src/provider/custom_sticker_package.dart';
import 'package:timuikit/src/provider/login_user_Info.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/utils/constant.dart';
import 'package:timuikit/utils/offline_push_config.dart';
import 'package:timuikit/utils/smsLogin.dart';
import 'package:timuikit/utils/theme.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/constants/emoji.dart';

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

  onKickedOffline() async {
// 被踢下线
    // 清除本地缓存，回到登录页TODO
    try {
      // Provider.of<ConversionModel>(context, listen: false).clear();
      // Provider.of<UserModel>(context, listen: false).clear();
      // Provider.of<CurrentMessageListModel>(context, listen: false).clear();
      // Provider.of<FriendListModel>(context, listen: false).clear();
      // Provider.of<FriendApplicationModel>(context, listen: false).clear();
      // Provider.of<GroupApplicationModel>(context, listen: false).clear();
      directToLogin();
      // 去掉存的一些数据
      removeLocalSetting();
      // ignore: empty_catches
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
    // getAllDiscussAndTopic();
    // 初始化IM SDK
    initIMSDKAndAddIMListeners();
    // 获取登录凭证全局数据
    getSmsLoginConfig();
    // 检测登录状态
    checkLogin();
  }

  getSmsLoginConfig() async {
    Map<String, dynamic>? data = await SmsLogin.getGlsb();
    int errorCode = data!['errorCode'];
    String errorMessage = data['errorMessage'];
    Map<String, dynamic> info = data['data'];
    if (errorCode != 0) {
      Utils.toast(errorMessage);
    } else {
      // ignore: non_constant_identifier_names
      String captcha_web_appid = info['captcha_web_appid'].toString();
      print(captcha_web_appid);
      // Provider.of<AppConfig>(context, listen: false)
      //     .updateAppId(captcha_web_appid);
    }
  }

  setTheme(String themeTypeString) {
    ThemeType themeType = DefTheme.themeTypeFromString(themeTypeString);
    Provider.of<DefaultThemeData>(context, listen: false).currentThemeType =
        themeType;
    Provider.of<DefaultThemeData>(context, listen: false).theme =
        DefTheme.defaultTheme[themeType]!;
    _coreInstance.setTheme(theme: DefTheme.defaultTheme[themeType]!);
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

  checkLogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("smsLoginToken");
    String? phone = prefs.getString("smsLoginPhone");
    String? userId = prefs.getString("smsLoginUserID");
    String themeTypeString = prefs.getString("themeType") ?? "";
    setTheme(themeTypeString);
    setCustomSticker();
    Utils.log("$token $phone $userId");
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

        V2TimCallback data =
            await _coreInstance.login(userID: userId, userSig: userSig);

        if (data.code != 0) {
          final failedReason = data.desc;
          Utils.toast(imt_para("登录失败 {{failedReason}}", "登录失败 $failedReason")(
              failedReason: failedReason));
          removeLocalSetting();
          directToLogin();
          return;
        }
        // TIMUIKitConversationController().loadData();
        directToHomePage();

        // getSelfInfo(userId, avatar);
        // getIMData();
      } else {
        // removeLocalSetting();
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
