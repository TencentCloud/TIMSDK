import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/src/pages/privacy/privacy.dart';
import 'package:timuikit/src/pages/privacy/privacy_agreement.dart';
import 'package:timuikit/utils/GenerateUserSig.dart';
import 'package:timuikit/utils/commonUtils.dart';
import 'package:timuikit/utils/offline_push_config.dart';
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset("assets/hero_image.png"),
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
              Container(
                margin: const EdgeInsets.only(right: 5),
                height: CommonUtils.adaptHeight(180),
                padding: const EdgeInsets.only(top: 10, left: 5),
                child: Column(
                  children: <Widget>[
                    Text(
                      imt("登录·即时通信"),
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: CommonUtils.adaptFontSize(64),
                      ),
                    ),
                    Text(
                      imt("体验群组聊天，音视频对话等IM功能"),
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: CommonUtils.adaptFontSize(28),
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              )
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

  String userID = '';
  bool checkboxSelected = false;

  unSelectedPrivacy() {
    Utils.toast(imt("需要同意隐私与用户协议"));
    return null;
  }

  directToHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
      (route) => false,
    );
  }

  userLogin() async {
    if (userID.trim() == '') {
      Utils.toast(imt("请输入用户名"));
      return;
    }

    String key = IMDemoConfig.key;
    int sdkAppId = IMDemoConfig.sdkappid;
    if (key == "") {
      Utils.toast("请在环境变量中写入key");
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
      final errorReason = data.desc;
      Utils.toast(imt_para("登录失败{{errorReason}}", "登录失败${errorReason}")(
          errorReason: errorReason));
      return;
    }
    await getIMData();

    directToHomePage();
  }

  getIMData() async {
    await Future.wait([
      setOfflinePushInfo(),
    ]);
  }

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
                        top: CommonUtils.adaptHeight(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: SizedBox(
                                  height: CommonUtils.adaptHeight(38),
                                  width: CommonUtils.adaptWidth(38),
                                  child: Checkbox(
                                    value: checkboxSelected,
                                    shape: const CircleBorder(),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkboxSelected = value!;
                                      });
                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                    },
                                  ),
                                ),
                              )),
                          Expanded(
                              child: Text.rich(
                            TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                      text: imt("我已阅读并同意"),
                                      style:
                                          const TextStyle(color: Colors.grey)),
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
                                      text: imt("和"),
                                      style:
                                          const TextStyle(color: Colors.grey)),
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
                                  const TextSpan(text: " ")
                                ]),
                            overflow: TextOverflow.clip,
                          ))
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: CommonUtils.adaptHeight(46),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              child: Text(imt("登录")),
                              onPressed: !checkboxSelected // 需要隐私协议勾选才可以登陆
                                  ? unSelectedPrivacy
                                  : userLogin,
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
