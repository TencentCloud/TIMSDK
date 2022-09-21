// ignore_for_file: unused_import, avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit_push_plugin/tim_ui_kit_push_plugin.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/privacy/privacy_webview.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/routes.dart';
import 'package:timuikit/utils/GenerateUserSig.dart';
import 'package:timuikit/utils/commonUtils.dart';
import 'package:timuikit/utils/push/channel/channel_push.dart';
import 'package:timuikit/utils/push/push_constant.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final double height = MediaQuery.of(context).size.height;
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Stack(
      alignment: Alignment.topCenter,
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
          child: Container(
            padding: EdgeInsets.only(top: height / 30, left: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: CommonUtils.adaptWidth(380),
                  width: CommonUtils.adaptWidth(140),
                  child: const Image(
                    image: AssetImage("assets/logo_transparent.png"),
                  ),
                ),
                Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      height: CommonUtils.adaptHeight(180),
                      padding: const EdgeInsets.only(top: 10, left: 12, right: 15),
                      child: Column(
                        children: <Widget>[
                          Text(
                            imt("腾讯云即时通信IM"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: CommonUtils.adaptFontSize(58),
                            ),
                          ),
                          Text(
                            imt("欢迎使用本 APP 体验腾讯云 IM 产品服务"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: CommonUtils.adaptFontSize(26),
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    )),
              ],
            ),
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

  String userID = '';

  @override
  initState() {
    super.initState();
    checkFirstEnter();
  }

  TextSpan webViewLink(String title, String url) {
    return TextSpan(
      text: imt(title),
      style: const TextStyle(
        color: Color.fromRGBO(0, 110, 253, 1),
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PrivacyDocument(title: title, url: url)));
        },
    );
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
                  webViewLink("《用户协议》",
                      'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html'),
                  TextSpan(
                    text: imt(", "),
                  ),
                  webViewLink("《隐私协议》",
                      'https://privacy.qq.com/document/preview/1cfe904fb7004b8ab1193a55857f7272'),
                  TextSpan(
                    text: imt(", "),
                  ),
                  webViewLink("《信息收集清单》",
                      'https://privacy.qq.com/document/preview/45ba982a1ce6493597a00f8c86b52a1e'),
                  TextSpan(
                    text: imt("和"),
                  ),
                  webViewLink("《信息共享清单》",
                      'https://privacy.qq.com/document/preview/dea84ac4bb88454794928b77126e9246'),
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

  directToHomePage() {
    Routes().directToHomePage();
  }

  userLogin() async {
    if (userID.trim() == '') {
      Utils.toast(imt("请输入用户名"));
      return;
    }

    String key = IMDemoConfig.key;
    int sdkAppId = IMDemoConfig.sdkappid;
    if (key == "") {
      Utils.toast(imt("请在环境变量中写入key"));
      return;
    }
    GenerateTestUserSig generateTestUserSig = GenerateTestUserSig(
      sdkappid: sdkAppId,
      key: key,
    );

    String userSig =
    generateTestUserSig.genSig(identifier: userID, expire: 99999);

    var data = await coreInstance.login(
      userID: userID,
      userSig: userSig,
    );
    if (data.code != 0) {
      final option1 = data.desc;
      Utils.toast(
          imt_para("登录失败{{option1}}", "登录失败$option1")(option1: option1));
      return;
    }
    directToHomePage();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(750, 1624),
      minTextAdapt: true,
    );
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
                    Padding(
                      padding:
                      EdgeInsets.only(top: CommonUtils.adaptFontSize(34)),
                      child: Text(
                        imt("用户名"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: CommonUtils.adaptFontSize(34),
                        ),
                      ),
                    ),
                    TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.only(left: CommonUtils.adaptWidth(14)),
                        hintText: imt("请输入用户名"),
                        hintStyle:
                        TextStyle(fontSize: CommonUtils.adaptFontSize(32)),
                        //
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        setState(() {
                          userID = v;
                        });
                      },
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
                              onPressed: userLogin,
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
