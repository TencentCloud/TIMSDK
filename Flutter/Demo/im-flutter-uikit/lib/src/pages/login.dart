// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/country_list_pick-1.0.1+5/lib/country_list_pick.dart';
import 'package:timuikit/country_list_pick-1.0.1+5/lib/country_selection_theme.dart';
import 'package:timuikit/country_list_pick-1.0.1+5/lib/support/code_country.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/privacy/privacy.dart';
import 'package:timuikit/src/pages/privacy/privacy_agreement.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/widgets/login_captcha.dart';
import 'package:timuikit/utils/commonUtils.dart';
import 'package:timuikit/utils/offline_push_config.dart';
import 'package:timuikit/utils/smsLogin.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

var timNewLogo = const AssetImage("assets/im_logo.png");

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isinit = false;
  String? oppoRegId;
  String captchaWebAppid = '';

  removeLocalSetting() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    prefs.remove("smsLoginToken");
    prefs.remove("smsLoginPhone");
    prefs.remove("smsLoginUserID");
    prefs.remove("channelListMain");
    prefs.remove("discussListMain");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: const Scaffold(
          body: AppLayout(),
          resizeToAvoidBottomInset: false,
        ));
  }
}

class AppLayout extends StatelessWidget {
  const AppLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Stack(
        children: const [
          AppLogo(),
          LoginForm(),
        ],
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                    theme.primaryColor ?? CommonColor.primaryColor
                  ]),
            ),
            child: Image.asset("assets/hero_image.png")),
        Positioned(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: CommonUtils.adaptWidth(380),
                width: CommonUtils.adaptWidth(200),
                child: Image(
                    image: timNewLogo,
                    width: CommonUtils.adaptWidth(380),
                    height: CommonUtils.adaptHeight(200)),
              ),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 5),
                height: CommonUtils.adaptHeight(180),
                padding: const EdgeInsets.only(top: 10, left: 5, right: 15),
                child: Column(
                  children: <Widget>[
                    Text(
                      imt("登录·即时通信"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: CommonUtils.adaptFontSize(64),
                      ),
                    ),
                    Text(
                      imt("体验群组聊天，音视频对话等IM功能"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: CommonUtils.adaptFontSize(28),
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              )),
            ],
          ),
        )
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final CoreServicesImpl coreInstance = TIMUIKitCore.getInstance();

  @override
  void initState() {
    super.initState();
    userSigEtController.addListener(checkIsValidForm);
    telEtController.addListener(checkIsValidForm);
    SmsLogin.initLoginService();
    setTel();
    checkFirstEnter();
  }

  @override
  void dispose() {
    userSigEtController.dispose();
    telEtController.dispose();
    super.dispose();
  }

  bool isGeted = false;
  String tel = '';
  int timer = 60;
  String sessionId = '';
  String code = '';
  bool isValid = false;
  TextEditingController userSigEtController = TextEditingController();
  TextEditingController telEtController = TextEditingController();
  String dialCode = "+86";
  String countryName = imt("中国大陆");

  checkIsValidForm() {
    if (userSigEtController.text.isNotEmpty &&
        telEtController.text.isNotEmpty) {
      setState(() {
        isValid = true;
      });
    } else if (isValid) {
      setState(() {
        isValid = false;
      });
    }
  }

  setTel() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? phone = prefs.getString("smsLoginPhone");
    if (phone != null) {
      telEtController.value = TextEditingValue(
        text: phone,
      );
      setState(() {
        tel = phone;
      });
    }
  }

  timeDown() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (timer == 0) {
          setState(() {
            timer = 60;
            isGeted = false;
          });
          return;
        }
        setState(() {
          timer = timer - 1;
        });
        timeDown();
      }
    });
  }

  void checkFirstEnter() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? firstTime = prefs.getString("firstTime");
    if (firstTime != null && firstTime == "true") {
      return;
    }
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          content: Text.rich(
            TextSpan(
                style: const TextStyle(
                    fontSize: 14, color: Colors.black, height: 2.0),
                children: [
                  TextSpan(
                    text: imt(
                        "欢迎使用腾讯云即时通信 IM，为保护您的个人信息安全，我们更新了《隐私政策》，主要完善了收集用户信息的具体内容和目的、增加了第三方SDK使用等方面的内容。"),
                  ),
                  const TextSpan(
                    text: "\n",
                  ),
                  TextSpan(
                    text: imt("请您点击"),
                  ),
                  TextSpan(
                    text: imt("《用户协议》"),
                    style: const TextStyle(
                      color: Color.fromRGBO(0, 110, 253, 1),
                    ),
                    // 设置点击事件
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UserAgreementPage()));
                      },
                  ),
                  TextSpan(
                    text: imt("和"),
                  ),
                  TextSpan(
                      text: imt("《隐私协议》"),
                      style: const TextStyle(
                        color: Color.fromRGBO(0, 110, 253, 1),
                      ),
                      // 设置点击事件
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacyAgreementPage(),
                            ),
                          );
                        }),
                  TextSpan(
                      text: imt("并仔细阅读，如您同意以上内容，请点击“同意并继续”，开始使用我们的产品与服务！")),
                ]),
            overflow: TextOverflow.clip,
          ),
          actions: [
            CupertinoDialogAction(
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 110, 253, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                  child: Text(imt("同意并继续"),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16))),
              onPressed: () {
                prefs.setString("firstTime", "true");
                Navigator.of(context).pop(true);
              },
            ),
            CupertinoDialogAction(
              child: Text(imt("不同意并退出"),
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
              isDestructiveAction: true,
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  // 获取验证码
  getLoginCode(context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      if (tel.isEmpty) {
        Utils.toast(imt("请输入手机号"));
        return;
      } else if (!RegExp(r"1[0-9]\d{9}$").hasMatch(tel)) {
        Utils.toast(imt("手机号格式错误"));
        return;
      } else {
        await _showMyDialog();
      }
    } else {
      Utils.toast(imt("无网络连接"));
    }
  }

  // 验证验证码后台下发短信
  vervifyPicture(messageObj) async {
    // String captchaWebAppid =
    //     Provider.of<AppConfig>(context, listen: false).appid;
    String phoneNum = "$dialCode$tel";
    final sdkAppid = IMDemoConfig.sdkappid.toString();
    print("sdkAppID$sdkAppid");
    Map<String, dynamic> response = await SmsLogin.vervifyPicture(
      phone: phoneNum,
      ticket: messageObj['ticket'],
      randstr: messageObj['randstr'],
      appId: sdkAppid,
    );
    int errorCode = response['errorCode'];
    String errorMessage = response['errorMessage'];
    if (errorCode == 0) {
      Map<String, dynamic> res = response['data'];
      String sid = res['sessionId'];
      setState(() {
        isGeted = true;
        sessionId = sid;
      });
      timeDown();
      Utils.toast(imt("验证码发送成功"));
    } else {
      Utils.toast(errorMessage);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          elevation: 0,
          content: SingleChildScrollView(
              child: LoginCaptcha(
                  onSuccess: vervifyPicture,
                  onClose: () {
                    Navigator.pop(context);
                  })),
        );
      },
    );
  }

  directToHomePage() {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) {
    //       return const HomePage();
    //     },
    //   ),
    // );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
      (route) => false,
    );
  }

  smsFristLogin() async {
    if (tel == '' && IMDemoConfig.productEnv) {
      Utils.toast(imt("请输入手机号"));
    }
    if (sessionId == '' || code == '') {
      Utils.toast(imt("验证码异常"));
      return;
    }
    String phoneNum = "$dialCode$tel";
    Map<String, dynamic> response = await SmsLogin.smsFirstLogin(
      sessionId: sessionId,
      phone: phoneNum,
      code: code,
    );
    int errorCode = response['errorCode'];
    String errorMessage = response['errorMessage'];

    if (errorCode == 0) {
      Map<String, dynamic> datas = response['data'];
      // userId, sdkAppId, sdkUserSig, token, phone:tel
      String userId = datas['userId'];
      String userSig = datas['sdkUserSig'];
      String token = datas['token'];
      String phone = datas['phone'];
      String avatar = datas['avatar'];
      var data = await coreInstance.login(
        userID: userId,
        userSig: userSig,
      );
      if (data.code != 0) {
        final errorReason = data.desc;
        Utils.toast(imt_para("登录失败{{errorReason}}", "登录失败$errorReason")(
            errorReason: errorReason));
        return;
      }

      final userInfos = coreInstance.loginUserInfo;
      if (userInfos != null) {
        await coreInstance.setSelfInfo(
          userFullInfo: V2TimUserFullInfo.fromJson(
            {
              "nickName": userId,
              "faceUrl": avatar,
            },
          ),
        );
      }

      // if (infos.code == 0) {
      //   if (infos.data![0].nickName == null ||
      //       infos.data![0].faceUrl == null ||
      //       infos.data![0].nickName == '' ||
      //       infos.data![0].faceUrl == '') {
      //     await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
      //       userFullInfo: V2TimUserFullInfo.fromJson(
      //         {
      //           "nickName": userId,
      //           "faceUrl": avatar,
      //         },
      //       ),
      //     );
      //     // SmsLogin.smsChangeUserInfo(
      //     //   userId: userId,
      //     //   token: token,
      //     // );
      //   }
      //   // Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
      // }
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      SharedPreferences prefs = await _prefs;
      prefs.setString("smsLoginToken", token);
      prefs.setString("smsLoginPhone", phone.replaceFirst(dialCode, ""));
      prefs.setString("smsLoginUserID", userId);
      setState(() {
        tel = '';
        code = '';
        timer = 60;
        isGeted = false;
      });
      userSigEtController.clear();
      telEtController.clear();
      await getIMData();
      // TIMUIKitConversationController().loadData();
      // Navigator.pop(context);
      directToHomePage();
    } else {
      Utils.toast(errorMessage);
    }
  }

  Future<void> getTotalUnread() async {
    // V2TimValueCallback<int> res = await IMSDK.getTotalUnreadMessageCount();
    // if (res.code == 0) {
    //   Provider.of<ConversationListProvider>(context, listen: false)
    //       .updateTotalUnreadCount(res.data!);
    // }
  }

  getIMData() async {
    await Future.wait([
      setOfflinePushInfo(),
      // getMessage(),
      // getTotalUnread(),
      // getGroupApplicationList(),
      // getFriendList(),
      // getFriendApplication(),
      // getChanelList(),
      // getDiscussList(),
      // checkAdmin()
    ]);
  }

  // Future<void> getDiscussList() async {
  //   Map<String, dynamic> data =
  //       await DisscussApi.getDiscussList(offset: 0, limit: 100);
  //   if (data['code'] == 0) {
  //     List<Map<String, dynamic>> list =
  //         List<Map<String, dynamic>>.from(data['data']['rows']);

  //     Provider.of<DiscussData>(context, listen: false).updateDiscussList(list);
  //   }
  // }

  // Future<void> getChanelList() async {
  //   Map<String, dynamic> data = await DisscussApi.getChanelList();
  //   if (data['code'] == 0) {
  //     List<Map<String, dynamic>> list =
  //         List<Map<String, dynamic>>.from(data['data']['rows']);
  //     Provider.of<DiscussData>(context, listen: false).updateChanelList(list);
  //   }
  // }

  // Future<void> checkAdmin() async {
  //   V2TimValueCallback<String> imRes =
  //       await TencentImSDKPlugin.v2TIMManager.getLoginUser();
  //   Map<String, dynamic> res = await DisscussApi.isValidateAdimn(
  //     userId: imRes.data!,
  //   );
  //   Provider.of<AppConfig>(
  //     context,
  //     listen: false,
  //   ).updateIsAdmin(res['data']['admin']);
  // }

  // Future<void> getFriendApplication() async {
  //   V2TimValueCallback<V2TimFriendApplicationResult> data =
  //       await TencentImSDKPlugin.v2TIMManager
  //           .getFriendshipManager()
  //           .getFriendApplicationList();
  //   if (data.code == 0) {
  //     if (data.data!.friendApplicationList!.isNotEmpty) {
  //       Provider.of<FriendApplicationModel>(context, listen: false)
  //           .setFriendApplicationResult(data.data!.friendApplicationList);
  //     } else {
  //       List<V2TimFriendApplication> list = List.empty(growable: true);
  //       Provider.of<FriendApplicationModel>(context, listen: false)
  //           .setFriendApplicationResult(list);
  //     }
  //   }
  // }

  // Future<void> getFriendList() async {
  //   V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
  //       await TencentImSDKPlugin.v2TIMManager
  //           .getFriendshipManager()
  //           .getFriendList();
  //   if (friendRes.code == 0) {
  //     List<V2TimFriendInfo?>? list = friendRes.data;
  //     if (list != null && list.isNotEmpty) {
  //       Provider.of<FriendListModel>(context, listen: false)
  //           .setFriendList(list);
  //     } else {
  //       Provider.of<FriendListModel>(context, listen: false)
  //           .setFriendList(List.empty(growable: true));
  //     }
  //   }
  // }

  // Future<void> getGroupApplicationList() async {
  //   // 获取加群申请
  //   V2TimValueCallback<V2TimGroupApplicationResult> res =
  //       await TencentImSDKPlugin.v2TIMManager
  //           .getGroupManager()
  //           .getGroupApplicationList();
  //   if (res.code == 0) {
  //     if (res.data!.groupApplicationList!.isNotEmpty) {
  //       Provider.of<GroupApplicationModel>(context, listen: false)
  //           .setGroupApplicationResult(
  //               List.castFrom(res.data!.groupApplicationList!));
  //     } else {
  //       List<V2TimGroupApplication> list = List.empty(growable: true);
  //       Provider.of<GroupApplicationModel>(context, listen: false)
  //           .setGroupApplicationResult(list);
  //     }
  //   } else {
  //   }
  // }

  // Future<void> getMessage() async {
  //   V2TimValueCallback<V2TimConversationResult> data =
  //       await IMSDK.getConversationList(
  //     nextSeq: "0",
  //     count: 100,
  //   );
  //   if (data.code == 0) {
  //     V2TimConversationResult result = data.data!;
  //     if (result.conversationList!.isNotEmpty) {
  //       List<V2TimConversation> newList =
  //           List.castFrom(result.conversationList!);
  //       Provider.of<ConversationListProvider>(
  //         context,
  //         listen: false,
  //       ).replaceConversationList(newList);
  //     }
  //   }
  // }

  Future<void> setOfflinePushInfo() async {
    String token = await OfflinePush.getTPNSToken();
    Utils.log("getTPNSToken $token");
    if (token != "") {
      coreInstance.setOfflinePushConfig(
        token: token,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
      // 设计稿尺寸：px
      designSize: const Size(750, 1624),
      context: context,
      minTextAdapt: true,
    );

    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Stack(
      children: [
        Positioned(
            bottom: CommonUtils.adaptHeight(200),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
              decoration: const BoxDecoration(
                //背景
                color: Colors.white,

                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                //设置四周边框
              ),
              // color: Colors.white,
              height: MediaQuery.of(context).size.height -
                  CommonUtils.adaptHeight(600),

              width: MediaQuery.of(context).size.width,
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imt("国家/地区"),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: CommonUtils.adaptFontSize(34)),
                    ),
                    CountryListPick(
                      appBar: AppBar(
                        // backgroundColor: Colors.blue,
                        title: Text(imt("选择你的国家区号"),
                            style: const TextStyle(fontSize: 17)),
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              theme.lightPrimaryColor ??
                                  CommonColor.lightPrimaryColor,
                              theme.primaryColor ?? CommonColor.primaryColor
                            ]),
                          ),
                        ),
                      ),

                      // if you need custome picker use this
                      pickerBuilder: (context, CountryCode? countryCode) {
                        print(countryCode);
                        return Row(
                          children: [
                            // 屏蔽伊朗 98
                            // 朝鲜 82 850
                            // 叙利亚 963
                            // 古巴 53
                            Text(
                                "${countryName == "China" ? "中国大陆" : countryName}(${countryCode?.dialCode})",
                                style: TextStyle(
                                    color: const Color.fromRGBO(17, 17, 17, 1),
                                    fontSize: CommonUtils.adaptFontSize(32))),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color.fromRGBO(17, 17, 17, 0.8),
                            ),
                          ],
                        );
                      },

                      // To disable option set to false
                      theme: CountryTheme(
                          isShowFlag: false,
                          isShowTitle: true,
                          isShowCode: true,
                          isDownIcon: true,
                          showEnglishName: true,
                          searchHintText: imt("请使用英文搜索"),
                          searchText: imt("搜索")),
                      // Set default value
                      initialSelection: '+86',
                      onChanged: (code) {
                        setState(() {
                          dialCode = code?.dialCode ?? "+86";
                          countryName = code?.name ?? imt("中国大陆");
                        });
                      },
                      useUiOverlay: false,
                      // Whether the country list should be wrapped in a SafeArea
                      useSafeArea: false,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 1, color: Colors.grey))),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: CommonUtils.adaptFontSize(34)),
                      child: Text(
                        imt("手机号"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: CommonUtils.adaptFontSize(34),
                        ),
                      ),
                    ),
                    TextField(
                      controller: telEtController,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.only(left: CommonUtils.adaptWidth(14)),
                        hintText: imt("请输入手机号"),
                        hintStyle:
                            TextStyle(fontSize: CommonUtils.adaptFontSize(32)),
                        //
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (v) {
                        setState(() {
                          tel = v;
                        });
                      },
                    ),
                    Padding(
                        child: Text(
                          imt("验证码"),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: CommonUtils.adaptFontSize(34)),
                        ),
                        padding: EdgeInsets.only(
                          top: CommonUtils.adaptHeight(35),
                        )),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: userSigEtController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 5),
                              hintText: imt("请输入验证码"),
                              hintStyle: TextStyle(
                                  fontSize: CommonUtils.adaptFontSize(32)),
                            ),
                            keyboardType: TextInputType.number,
                            //校验密码
                            onChanged: (value) {
                              if ('$code$code' == value && value.length > 5) {
                                //键入重复的情况
                                setState(() {
                                  userSigEtController.value = TextEditingValue(
                                    text: code, //不赋值新的 用旧的;
                                    selection: TextSelection.fromPosition(
                                      TextPosition(
                                          affinity: TextAffinity.downstream,
                                          offset: code.length),
                                    ), //  此处是将光标移动到最后,
                                  );
                                });
                              } else {
                                //第一次输入验证码
                                setState(() {
                                  userSigEtController.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                      TextPosition(
                                          affinity: TextAffinity.downstream,
                                          offset: value.length),
                                    ), //  此处是将光标移动到最后,
                                  );
                                  code = value;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: CommonUtils.adaptWidth(200),
                          child: ElevatedButton(
                            child: isGeted
                                ? Text(timer.toString())
                                : Text(
                                    imt("获取验证码"),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: CommonUtils.adaptFontSize(24),
                                    ),
                                  ),
                            onPressed: isGeted
                                ? null
                                : () {
                                    //获取验证码
                                    FocusScope.of(context).unfocus();
                                    getLoginCode(context);
                                  },
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: CommonUtils.adaptHeight(46),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              child: Text(imt("登陆")),
                              onPressed: isValid ? smsFristLogin : null,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    )
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
