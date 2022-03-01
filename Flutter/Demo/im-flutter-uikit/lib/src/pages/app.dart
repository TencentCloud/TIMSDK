import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/src/pages/no_connect.dart';
import 'package:timuikit/utils/offline_push_config.dart';
import 'package:timuikit/utils/smsLogin.dart';
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

  removeLocalSetting() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    prefs.remove("smsLoginToken");
    prefs.remove("smsLoginPhone");
    prefs.remove("smsLoginUserID");
    prefs.remove("channelListMain");
    prefs.remove("discussListMain");
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

  checkLogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("smsLoginToken");
    String? phone = prefs.getString("smsLoginPhone");
    String? userId = prefs.getString("smsLoginUserID");
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
        String avatar = datas['avatar'];
        print(_coreInstance.loginUserInfo);

        V2TimCallback data =
            await _coreInstance.login(userID: userId, userSig: userSig);

        if (data.code != 0) {
          final failedReason = data.desc;
          Utils.toast(imt_para("登录失败 {{failedReason}}", "登录失败 ${failedReason}")(failedReason: failedReason));
          removeLocalSetting();
          directToLogin();
          return;
        }
        // TIMUIKitConversationController().loadData();
        directToHomePage();

        // getSelfInfo(userId, avatar);
        // getIMData();
      } else {
        removeLocalSetting();
        Utils.toast(errorMessage);
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

  @override
  void initState() {
    super.initState();
    subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return const NoConnectivityPage();
            },
          ),
        );
      }
    });
    OfflinePush.init();
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
