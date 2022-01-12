import 'dart:convert';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/config.dart';
import 'package:discuss/provider/conversationlistprovider.dart';
import 'package:discuss/provider/friend.dart';
import 'package:discuss/provider/friendapplication.dart';
import 'package:discuss/provider/groupapplication.dart';
import 'package:discuss/utils/GenerateTestUserSig.dart';

import 'package:discuss/utils/imsdk.dart';
import 'package:discuss/utils/offline_push_config.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

import 'package:discuss/pages/privacy/user_agreement.dart';
import 'package:discuss/provider/config.dart';

import 'package:discuss/provider/user.dart';
import 'package:discuss/utils/smslogin.dart';
import 'package:discuss/utils/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../pages/privacy/privacy_agreement.dart' show PrivacyAgreementPage;

var timLogo = const AssetImage("images/logo.png");

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isinit = false;
  String? oppoRegId;
  String captchaWebAppid = '';

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
      Provider.of<AppConfig>(context, listen: false)
          .updateAppId(captcha_web_appid);
    }
  }

  removeLocalSetting() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    prefs.remove("smsLoginToken");
    prefs.remove("smsLoginPhone");
    prefs.remove("smsLoginUserID");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: const Scaffold(
          body: AppLayout(),
        ));
  }
}

class AppLayout extends StatelessWidget {
  const AppLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AppLogo(),
        Expanded(
          child: LoginForm(),
        )
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192.0,
      color: hexToColor("006fff"),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(
        top: 108.0,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 90,
            width: 90,
            child: Image(
              image: timLogo,
              width: 90.0,
              height: 90.0,
            ),
          ),
          Container(
            height: 90.0,
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: Column(
              children: const <Widget>[
                Text(
                  '登录·即时通信',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 28,
                  ),
                ),
                Text(
                  '体验群组聊天，音视频对话等IM功能',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 12,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          )
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  void initState() {
    super.initState();
    setTel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isGeted = false;
  String userName = ""; // userName其实即为登陆的userId
  String tel = '';
  int timer = 60;
  String sessionId = '';
  String code = '';
  bool checkboxSelected = false;
  TextEditingController userSigEtController = TextEditingController();
  TextEditingController telEtController = TextEditingController();

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
    });
  }

  // 获取验证码
  getLoginCode(context) async {
    if (tel.isEmpty) {
      Utils.toast('请输入手机号');
      return;
    } else if (!RegExp(r"1[0-9]\d{9}$").hasMatch(tel)) {
      Utils.toast('手机号格式错误');
      return;
    } else {
      await _showMyDialog();
    }
  }

  // 验证验证码后台下发短信
  vervifyPicture(messageObj) async {
    String captchaWebAppid =
        Provider.of<AppConfig>(context, listen: false).appid;
    Map<String, dynamic> response = await SmsLogin.vervifyPicture(
      phone: "+86$tel",
      ticket: messageObj['ticket'],
      randstr: messageObj['randstr'],
      appId: captchaWebAppid,
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
      Utils.toast("验证码发送成功");
    } else {
      Utils.toast(errorMessage);
    }
  }

  unSelectedPrivacy() {
    Utils.toast("需要同意隐私与用户协议");
    return null;
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 160,
              height: 280,
              child: WebView(
                initialUrl: IMDiscussConfig.captchaUrl,
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: {
                  JavascriptChannel(
                      name: 'messageHandler',
                      onMessageReceived: (JavascriptMessage message) {
                        try {
                          var messageObj = jsonDecode(message.message);
                          vervifyPicture(messageObj);
                        } catch (e) {
                          Utils.toast("图片验证码校验失败");
                        }
                        Navigator.pop(context);
                      }),
                  JavascriptChannel(
                      name: 'capClose',
                      onMessageReceived: (JavascriptMessage message) {
                        Navigator.pop(context);
                      })
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // 根据key计算得到userSign进行登陆
  keyLogin() async {
    String userId = userName;
    String key = IMDiscussConfig.key;
    int sdkAppId = IMDiscussConfig.sdkappid;
    if (key == "") {
      Utils.toast("请在环境变量中写入key");
      return;
    }

    GenerateTestUserSig generateTestUserSig = GenerateTestUserSig(
      sdkappid: sdkAppId,
      key: key,
    );
    String userSign =
        generateTestUserSig.genSig(identifier: userId, expire: 99999);
    //identifier 为uerID
    // expire 为userSign的有效期时间
    var data = await TencentImSDKPlugin.v2TIMManager
        .login(userID: userId, userSig: userSign);
    if (data.code != 0) {
      Utils.toast("登录失败${data.desc}");
      return;
    }
    V2TimValueCallback<List<V2TimUserFullInfo>> infos =
        await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
      userIDList: [userId],
    );
    if (infos.code == 0) {
      if (infos.data![0].nickName == null ||
          infos.data![0].faceUrl == null ||
          infos.data![0].nickName == '' ||
          infos.data![0].faceUrl == '') {
        await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
          userFullInfo: V2TimUserFullInfo.fromJson(
            {
              "nickName": userId,
              "faceUrl": infos.data![0].faceUrl ?? "",
            },
          ),
        );
      }
      Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;

    prefs.setString("userId", userId);

    setState(() {
      userName = "";
      tel = '';
      code = '';
      timer = 60;
      isGeted = false;
    });
    userSigEtController.clear();
    telEtController.clear();
    await getIMData();
    Navigator.pop(context);
  }

  // 短信登陆
  smsFristLogin() async {
    if (tel == '' && IMDiscussConfig.productEnv) {
      Utils.toast("请输入手机号");
    }
    if (sessionId == '' || code == '') {
      Utils.toast("验证码异常");
      return;
    }
    Map<String, dynamic> response = await SmsLogin.smsFirstLogin(
      sessionId: sessionId,
      phone: "+86$tel",
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
      var data = await TencentImSDKPlugin.v2TIMManager.login(
        userID: userId,
        userSig: userSig,
      );
      if (data.code != 0) {
        Utils.toast("登录失败${data.desc}");
        return;
      }
      V2TimValueCallback<List<V2TimUserFullInfo>> infos =
          await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
        userIDList: [userId],
      );
      if (infos.code == 0) {
        if (infos.data![0].nickName == null ||
            infos.data![0].faceUrl == null ||
            infos.data![0].nickName == '' ||
            infos.data![0].faceUrl == '') {
          await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
            userFullInfo: V2TimUserFullInfo.fromJson(
              {
                "nickName": userId,
                "faceUrl": avatar,
              },
            ),
          );
          // SmsLogin.smsChangeUserInfo(
          //   userId: userId,
          //   token: token,
          // );
        }
        Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
      }
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      SharedPreferences prefs = await _prefs;
      prefs.setString("smsLoginToken", token);
      prefs.setString("smsLoginPhone", phone.replaceFirst("+86", ""));
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
      Navigator.pop(context);
    } else {
      Utils.toast(errorMessage);
    }
  }

  getTatalUnread() async {
    V2TimValueCallback<int> res = await IMSDK.getTotalUnreadMessageCount();
    if (res.code == 0) {
      Provider.of<ConversationListProvider>(context, listen: false)
          .updateTotalUnreadCount(res.data!);
    }
  }

  getIMData() async {
    setOfflinePushInfo();
    getMessage();
    getTatalUnread();
    getGroupApplicationList();
    getFriendList();
    getFriendApplication();
  }

  getFriendApplication() async {
    V2TimValueCallback<V2TimFriendApplicationResult> data =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendApplicationList();
    if (data.code == 0) {
      if (data.data!.friendApplicationList!.isNotEmpty) {
        Provider.of<FriendApplicationModel>(context, listen: false)
            .setFriendApplicationResult(data.data!.friendApplicationList);
      } else {
        List<V2TimFriendApplication> list = List.empty(growable: true);
        Provider.of<FriendApplicationModel>(context, listen: false)
            .setFriendApplicationResult(list);
      }
    }
  }

  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo?>? list = friendRes.data;
      if (list != null && list.isNotEmpty) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(list);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  getGroupApplicationList() async {
    // 获取加群申请
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.data!.groupApplicationList!.isNotEmpty) {
        Provider.of<GroupApplicationModel>(context, listen: false)
            .setGroupApplicationResult(res.data!.groupApplicationList);
      } else {
        List<V2TimGroupApplication> list = List.empty(growable: true);
        Provider.of<GroupApplicationModel>(context, listen: false)
            .setGroupApplicationResult(list);
      }
    } else {
      Utils.log("获取加群申请失败${res.desc}");
    }
  }

  getMessage() async {
    V2TimValueCallback<V2TimConversationResult> data =
        await IMSDK.getConversationList(
      nextSeq: "0",
      count: 100,
    );
    if (data.code == 0) {
      V2TimConversationResult result = data.data!;
      if (result.conversationList!.isNotEmpty) {
        List<V2TimConversation> newList =
            List.castFrom(result.conversationList!);
        Provider.of<ConversationListProvider>(
          context,
          listen: false,
        ).replaceConversationList(newList);
      }
    }
  }

  setOfflinePushInfo() async {
    String token = await OfflinePush.getDeviceToken();
    Utils.log("getDeviceToken $token");
    if (token != "") {
      TencentImSDKPlugin.v2TIMManager
          .getOfflinePushManager()
          .setOfflinePushConfig(
            businessID: IMDiscussConfig.pushConfig['ios']!['dev']!,
            token: token,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Form(
        child: Column(
          children: [
            TextField(
              autofocus: false,
              controller: telEtController,
              decoration: const InputDecoration(
                labelText: "用户名",
                hintText: "请输入userId",
                icon: Icon(Icons.account_circle),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(() {
                  userName = v;
                });
              },
            ),
            // TextField(
            //   autofocus: false,
            //   controller: telEtController,
            //   decoration: const InputDecoration(
            //     labelText: "手机号",
            //     hintText: "请输入手机号",
            //     icon: Icon(Icons.phone_android),
            //   ),
            //   keyboardType: TextInputType.number,
            //   onChanged: (v) {
            //     setState(() {
            //       tel = v;
            //     });
            //   },
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: userSigEtController,
            //         decoration: const InputDecoration(
            //           labelText: "验证码",
            //           hintText: "请输入验证码",
            //           icon: Icon(Icons.lock),
            //         ),
            //         keyboardType: TextInputType.number,
            //         //校验密码
            //         onChanged: (v) {
            //           setState(() {
            //             code = v;
            //           });
            //         },
            //       ),
            //     ),
            //     SizedBox(
            //       width: 120,
            //       child: ElevatedButton(
            //         child:
            //             isGeted ? Text(timer.toString()) : const Text("获取验证码"),
            //         onPressed: isGeted
            //             ? null
            //             : () {
            //                 //获取验证码
            //                 getLoginCode(context);
            //               },
            //       ),
            //     )
            //   ],
            // ),
            Container(
              margin: const EdgeInsets.only(
                top: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Checkbox(
                        value: checkboxSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            checkboxSelected = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text.rich(
                    TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                              text: "我已阅读并同意",
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                              text: "<<隐私协议>>",
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
                          const TextSpan(
                              text: "和", style: TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: "<<用户协议>>",
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
                          const TextSpan(
                            text: "，并授权腾讯云使用该IM账号（昵称、头像、电话号码）进行统一管理",
                            style: TextStyle(color: Colors.grey),
                            // 设置点击事件
                            // recognizer: TapGestureRecognizer()
                            //   ..onTap = () {
                            //     Navigator.pushNamed(context, "/privacy");
                            //   },
                          ),
                        ]),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                  ))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 28,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("登录"),
                      onPressed: !checkboxSelected // 需要隐私协议勾选才可以登陆
                          ? unSelectedPrivacy
                          : keyLogin,
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
    );
  }
}
