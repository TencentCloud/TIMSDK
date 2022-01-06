import 'dart:convert';
import 'dart:io';
// import 'package:device_info/device_info.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

import 'package:tencent_im_sdk_plugin_example/pages/home/home.dart';
import 'package:tencent_im_sdk_plugin_example/pages/privacy/user_agreement.dart';
import 'package:tencent_im_sdk_plugin_example/provider/conversion.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friend.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friendApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/groupApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/user.dart';
import 'package:tencent_im_sdk_plugin_example/utils/GenerateTestUserSig.dart';
import 'package:tencent_im_sdk_plugin_example/utils/config.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:tencent_tpns_oppo_push_plugin/enum/importance.dart';
// import 'package:tencent_tpns_oppo_push_plugin/tencent_tpns_oppo_push_plugin.dart';
// import 'package:tencent_tpns_vivo_push_plugin/tencent_tpns_vivo_push_plugin.dart';
// import 'package:tencent_tpns_xiaomi_push_plugin/tencent_tpns_xiaomi_push_plugin.dart';

import '../../pages/privacy/privacy_agreement.dart' show PrivacyAgreementPage;
// import '../../pages/privacy/user_agreement.dart' show Test, UserAgreementPage;

var timLogo = AssetImage("images/logo.png");

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isinit = false;
  String? oppoRegId;

  void initState() {
    super.initState();
    init();
  }

  init() async {
    await initSDK();
    setState(() {
      isinit = true;
    });
    await islogin();
    // await toHomePage();
    // await setOfflinepush();
  }

  offlinePushCallback(data) {
    if (data['name'] == 'onRegister') {
      if (data['responseCode'] == 0) {
        setState(() {
          oppoRegId = data['data'];
        });
        TencentImSDKPlugin.v2TIMManager
            .getOfflinePushManager()
            .setOfflinePushConfig(businessID: 7005, token: data['data'])
            .then((res) {
          if (res.code == 0) {
            Utils.toast("设置推送成功");
          } else {
            Utils.toast("设置推送失败${res.desc}");
          }
        }).catchError((err) {
          Utils.toast("设置推送失败$err");
          print("设置推送失败$err");
        });
      }
    }
  }

  setOfflinepush() async {
    if (Platform.isAndroid) {
      // DeviceInfoPlugin info = new DeviceInfoPlugin();
      // AndroidDeviceInfo androidInfo = await info.androidInfo;
      // print("androidInfo.brand ${androidInfo.brand}");
      // String brand = androidInfo.brand;
      // switch (brand) {
      //   case 'google':
      //     break;
      //   case 'xiaomi':
      //     initXiaomiPush();
      //     break;
      //   case 'OPPO':
      //     initOppoPush();
      //     break;
      //   case 'vivo':
      //     // initVivoPush();
      //     break;
      // }
    } else {
      //去掉推送
      // V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
      //     .getAPNSManager()
      //     .setAPNS(businessID: 23945);
      // if (res.code == 0) {
      //   Utils.toast("设置推送成功");
      // } else {
      //   Utils.toast("设置推送失败${res.desc}");
      // }
    }
  }

  // initVivoPush() async {
  //   TencentTpnsVivoPushPlugin.initialize();
  //   String regId = await TencentTpnsVivoPushPlugin.getRegId();
  //   print('regId$regId');
  // }

  // initXiaomiPush() async {
  //   TencentTpnsXiaomiPushPlugin.registerPush(
  //     appID: "2882303761518516314",
  //     appToken: "5141851613314",
  //   );
  //   String regId = await TencentTpnsXiaomiPushPlugin.getRegId();
  //   TencentTpnsXiaomiPushPlugin.enablePush();
  //   if (regId.isNotEmpty) {
  //     TencentImSDKPlugin.v2TIMManager
  //         .getOfflinePushManager()
  //         .setOfflinePushConfig(businessID: 5218, token: regId)
  //         .then((res) {
  //       if (res.code == 0) {
  //         Utils.toast("设置推送成功");
  //       } else {
  //         Utils.toast("设置推送失败${res.desc}");
  //       }
  //     }).catchError((err) {
  //       Utils.toast("设置推送失败$err");
  //       print("设置推送失败$err");
  //     });
  //   } else {
  //     Utils.toast("获取小米regid失败");
  //   }
  // }

  // initOppoPush() async {
  //   TencentTpnsOppoPushPlugin.init(needLog: true);
  //   TencentTpnsOppoPushPlugin.setCallback(callback: offlinePushCallback);
  //   bool isSupport = await TencentTpnsOppoPushPlugin.isSupportPush();
  //   if (isSupport) {
  //     TencentTpnsOppoPushPlugin.createNotificationChannel(
  //       channel: "tuikit",
  //       name: "test",
  //       description: "test description",
  //       importance: Importance.IMPORTANCE_HIGH,
  //     );
  //     TencentTpnsOppoPushPlugin.register(
  //       appKey: "cf080880fc9747cf8f09baa6d806fb85",
  //       appSecret: "75bb981450bc4753b93b1978fd014c95",
  //     );
  //     TencentTpnsOppoPushPlugin.resumePush();
  //   }
  // }

  // toHomePage() async {
  //   const userId = "lexuslin";
  //   const userSig =
  //       "eJwtzE8LgjAcxvH3smthv003-0CHwIpo0CG7dSm24pfOpjMxoveeqcfn88D3QzJ59Fpdk4QwD8h82Kh02eANBy5093IFltPnVH6xFhVJaABAo9DnbHx0Z7HWvXPOGQCM2qD5mwAR0ihi4VTBe59W6Xof680OjTPPoArUtfJnPEMpVwdGY3ifFyexfeRpK92SfH8q-zJ8";
  //   V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
  //     userID: userId,
  //     userSig: userSig,
  //   );

  //   V2TimCallback data2 = await TencentImSDKPlugin.v2TIMManager
  //       .getAPNSManager()
  //       .setAPNS(businessID: 23945);

  //   V2TimValueCallback<List<V2TimUserFullInfo>> infos = await TencentImSDKPlugin
  //       .v2TIMManager
  //       .getUsersInfo(userIDList: [userId]);
  //   Provider.of<UserModel>(context, listen: false).setInfo(infos.data[0]);

  //   Navigator.push(
  //     context,
  //     new MaterialPageRoute(
  //       builder: (context) => HomePage(),
  //     ),
  //   );
  // }

  islogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("token");
    String? sessionId = prefs.getString("sessionId");
    String? phone = prefs.getString("phone");
    String? code = prefs.getString("code");

    if (token != null && sessionId != null && phone != null && code != null) {
      Dio dio = new Dio();
      Response response = await dio.get(
        "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms",
        queryParameters: {
          "phone": "86$phone",
          "method": "login",
          "sessionId": sessionId,
          "token": token,
          "code": code
        },
      );
      print(response);
      if (response.data['errorCode'] == 0) {
        //登录成功
        String userId = response.data['data']['userId'];
        String userSig = response.data['data']['userSig'];
        String avatar = response.data['data']['avatar'];

        V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
          userID: userId,
          userSig: userSig,
        );

        if (data.code != 0) {
          print('登录失败${data.desc}');
          setState(() {
            isinit = true;
          });
          return;
        } else {
          print("登录成功");
        }

        // await Tools.setOfflinepush(context);

        V2TimValueCallback<List<V2TimUserFullInfo>> infos =
            await TencentImSDKPlugin.v2TIMManager
                .getUsersInfo(userIDList: [userId]);
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
          }
          Provider.of<UserModel>(context, listen: false)
              .setInfo(infos.data![0]);
        } else {}
        try {
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) {
                return HomePage();
              },
            ),
          );
        } catch (err) {
          print(err);
        }
      } else {}
    } else {}
    setState(() {
      isinit = true;
    });
  }

  void onSelfInfoUpdated() async {
    //自己信息更新，从新获取自己的信息；
    V2TimValueCallback<String> usercallback =
        await TencentImSDKPlugin.v2TIMManager.getLoginUser();
    V2TimValueCallback<List<V2TimUserFullInfo>> infos = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: [usercallback.data!]);
    if (infos.code == 0) {
      Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
    }
  }

  void onKickedOffline() async {
// 被踢下线
    // 清除本地缓存，回到登录页TODO
    try {
      Provider.of<ConversionModel>(context, listen: false).clear();
      Provider.of<UserModel>(context, listen: false).clear();
      Provider.of<CurrentMessageListModel>(context, listen: false).clear();
      Provider.of<FriendListModel>(context, listen: false).clear();
      Provider.of<FriendApplicationModel>(context, listen: false).clear();
      Provider.of<GroupApplicationModel>(context, listen: false).clear();
      // 去掉存的一些数据
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      SharedPreferences prefs = await _prefs;
      prefs.remove('token');
      prefs.remove('sessionId');
      prefs.remove('phone');
      prefs.remove('code');
    } catch (err) {
      print("someError");
      print(err);
    }
    print("被踢下线了");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  void onReceiveJoinApplicationonMemberEnter() async {
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.length > 0) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        }
      }
    } else {
      print("获取加群申请失败${res.desc}");
    }
  }

  void onRecvNewMessage(V2TimMessage message) {
    try {
      List<V2TimMessage> messageList = List.empty(growable: true);

      messageList.add(message);

      print("c2c_${message.sender}");
      String key;
      if (message.groupID == null) {
        key = "c2c_${message.sender}";
      } else {
        key = "group_${message.groupID}";
      }
      print("conterkey_$key");
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, messageList);
    } catch (err) {
      print(err);
    }
  }

  void onRecvC2CReadReceipt(List<V2TimMessageReceipt> list) {
    print('收到了新消息 已读回执');
    list.forEach((element) {
      print("已读回执${element.userID} ${element.timestamp}");
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .updateC2CMessageByUserId(element.userID);
    });
  }

  void onSendMessageProgress(V2TimMessage message, int progress) {
// 消息进度
    String key;
    if (message.groupID == null) {
      key = "c2c_${message.userID}";
    } else {
      key = "group_${message.groupID}";
    }
    try {
      Provider.of<CurrentMessageListModel>(
        context,
        listen: false,
      ).addOneMessageIfNotExits(
        key,
        message,
      );
    } catch (err) {
      print("error $err");
    }
    print(
        "消息发送进度 $progress ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
  }

  void
      onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.length > 0) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  void onFriendApplicationListAdded(List<V2TimFriendApplication> list) {
    // 收到加好友申请,添加双向好友时双方都会周到这个回调，这时要过滤掉type=2的不显示
    print("收到加好友申请");
    List<V2TimFriendApplication> newlist = List.empty(growable: true);
    list.forEach((element) {
      if (element.type != 2) {
        newlist.add(element);
      }
    });
    if (newlist.isNotEmpty) {
      Provider.of<FriendApplicationModel>(context, listen: false)
          .setFriendApplicationResult(newlist);
    }
  }

  Map<String, V2TimConversation> conversationlistToMap(
      List<V2TimConversation> list) {
    Map<int, V2TimConversation> convsersationMap = list.asMap();
    Map<String, V2TimConversation> newConversation = new Map();
    convsersationMap.forEach((key, value) {
      newConversation[value.conversationID] = value;
    });
    return newConversation;
  }

  initSDK() async {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    await timManager.initSDK(
      sdkAppID: Config.sdkappid,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: new V2TimSDKListener(
        onConnectFailed: (code, error) {},
        onConnectSuccess: () {},
        onConnecting: () {},
        onKickedOffline: () {
          onKickedOffline();
        },
        onSelfInfoUpdated: (info) {
          onSelfInfoUpdated();
        },
        onUserSigExpired: () {},
      ),
    );

    print("initSDK");

    //简单监听
    timManager.addSimpleMsgListener(
      listener: new V2TimSimpleMsgListener(
        onRecvC2CCustomMessage: (msgID, sender, customData) {},
        onRecvC2CTextMessage: (msgID, userInfo, text) {},
        onRecvGroupCustomMessage: (msgID, groupID, sender, customData) {},
        onRecvGroupTextMessage: (msgID, groupID, sender, customData) {},
      ),
    );

    //群组监听
    timManager.setGroupListener(
      listener: new V2TimGroupListener(
        onApplicationProcessed: (groupID, opUser, isAgreeJoin, opReason) {},
        onGrantAdministrator: (groupID, opUser, memberList) {},
        onGroupAttributeChanged: (groupID, groupAttributeMap) {},
        onGroupCreated: (groupID) {},
        onGroupDismissed: (groupID, opUser) {},
        onGroupInfoChanged: (groupID, changeInfos) {},
        onGroupRecycled: (groupID, opUser) {},
        onMemberEnter: (groupID, memberList) {
          onReceiveJoinApplicationonMemberEnter();
        },
        onMemberInfoChanged: (groupID, v2TIMGroupMemberChangeInfoList) {},
        onMemberInvited: (groupID, opUser, memberList) {},
        onMemberKicked: (groupID, opUser, memberList) {},
        onMemberLeave: (groupID, member) {},
        onQuitFromGroup: (groupID) {},
        onReceiveJoinApplication: (groupID, member, opReason) {
          onReceiveJoinApplicationonMemberEnter();
        },
        onReceiveRESTCustomData: (groupID, customData) {},
        onRevokeAdministrator: (groupID, opUser, memberList) {},
      ),
    );
    //高级消息监听
    timManager.getMessageManager().addAdvancedMsgListener(
          listener: new V2TimAdvancedMsgListener(
            onRecvC2CReadReceipt: (receiptList) {
              onRecvC2CReadReceipt(receiptList);
            },
            onRecvMessageRevoked: (msgID) {},
            onRecvNewMessage: (msg) {
              onRecvNewMessage(msg);
            },
            onSendMessageProgress: (message, progress) {
              onSendMessageProgress(message, progress);
            },
          ),
        );

    timManager.getFriendshipManager().setFriendListener(
          listener: new V2TimFriendshipListener(
            onBlackListAdd: (infoList) {},
            onBlackListDeleted: (userList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendApplicationListAdded: (applicationList) {
              onFriendApplicationListAdded(applicationList);
            },
            onFriendApplicationListDeleted: (userIDList) {},
            onFriendApplicationListRead: () {},
            onFriendInfoChanged: (infoList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendListAdded: (users) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendListDeleted: (userList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
          ),
        );
    //会话监听
    timManager.getConversationManager().setConversationListener(
          listener: new V2TimConversationListener(
            onConversationChanged: (conversationList) {
              try {
                Provider.of<ConversionModel>(context, listen: false)
                    .setConversionList(conversationList);
                //如果当前会话在使用中，也更新一下

              } catch (e) {}
            },
            onNewConversation: (conversationList) {
              try {
                Provider.of<ConversionModel>(context, listen: false)
                    .setConversionList(conversationList);
                //如果当前会话在使用中，也更新一下

              } catch (e) {}
            },
            onSyncServerFailed: () {},
            onSyncServerFinish: () {},
            onSyncServerStart: () {},
          ),
        );
    timManager.getSignalingManager().addSignalingListener(
          listener: new V2TimSignalingListener(
            onInvitationCancelled: (inviteID, inviter, data) {},
            onInvitationTimeout: (inviteID, inviteeList) {},
            onInviteeAccepted: (inviteID, invitee, data) {},
            onInviteeRejected: (inviteID, invitee, data) {},
            onReceiveNewInvitation:
                (inviteID, inviter, groupID, inviteeList, data) {},
          ),
        );
    print("初始化完成了");
  }

  @override
  Widget build(BuildContext context) {
    return (!isinit) ? new WaitHomeWidget() : new HomeWidget();
  }
}

class WaitHomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WaitHomeWidgetState();
}

class WaitHomeWidgetState extends State<WaitHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new AppLayout(),
    );
  }
}

class AppLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(),
        Expanded(
          child: LoginForm(),
        )
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192.0,
      color: CommonColors.getThemeColor(),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        top: 108.0,
      ),
      child: Row(
        children: <Widget>[
          Container(
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
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Column(
              children: <Widget>[
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
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  void initState() {
    super.initState();
    this.setTel();
  }

  bool isGeted = false;
  String tel = '';
  String pwd = '';
  int timer = 60;
  String token = '';
  String sessionId = '';
  bool checkboxSelected = false;
  TextEditingController userSigEtController = TextEditingController();
  TextEditingController telEtController = TextEditingController();
  void getHttp() async {
    try {
      Response response = await Dio().get(
        "https://service-qr8jjnpm-1256635546.gz.apigw.tencentcs.com/release/getUserSig?userId=xingchenhe",
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  setTel() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString("flutter_userID") != null
        ? prefs.getString("flutter_userID")
        : "";
    telEtController.value = new TextEditingValue(
      text: userId!,
    );
    setState(() {
      tel = userId;
    });
  }

  timeDown() {
    new Future.delayed(const Duration(milliseconds: 1000), () {
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
    const int sdkappid = int.fromEnvironment('SDK_APPID', defaultValue: 0);
    const String key = String.fromEnvironment('KEY', defaultValue: "");
    print("让我看看${Config.sdkappid},${Config.productEnv}");
    print(
        "我拿到的环境变量key:$key,sdkappid:$sdkappid,test:${int.fromEnvironment('SDK_APPID', defaultValue: 0)}");
    print(int.fromEnvironment('SDK_APPID', defaultValue: 0));
    if (tel.length == 0) {
      Utils.toast('请输入手机号');
      return;
    } else if (!new RegExp(r"1[0-9]\d{9}$").hasMatch(tel)) {
      Utils.toast('手机号格式错误');
      return;
    } else {
      await _showMyDialog();
    }
  }

  // 获得手机登陆验证码
  void sendSms(messageObj) async {
    Dio dio = new Dio();
    Response response = await dio.get(
      "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/smsImg",
      // print("$tel,${ messageObj["ticket"]}");
      queryParameters: {
        "phone": "86${this.tel}",
        "ticket": messageObj["ticket"],
        "randstr": messageObj["randstr"]
        //"method": "getSms",
      },
    );
    print(response);
    try {
      if (response.data['errorCode'] == 0) {
        print(response.data['data']['sessionId']);
        Utils.toast("验证码发送成功");
      } else {
        Utils.toast(response.data['errorMessage']);
      }
      setState(() {
        isGeted = true;
        sessionId = response.data['data']['sessionId'];
      });
      timeDown();
    } catch (err) {
      print(err);
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
            child: Container(
              width: 200,
              height: 200,
              child: WebView(
                initialUrl:
                    'https://imgcache.qq.com/operation/dianshi/other/index.e7ef9e022229b9167136a9ed48572f258fe7d528.html',
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: Set.from([
                  JavascriptChannel(
                      name: 'messageHandler',
                      onMessageReceived: (JavascriptMessage message) {
                        try {
                          var messageObj = jsonDecode(message.message);
                          sendSms(messageObj);
                          Navigator.pop(context);
                        } catch (e) {
                          Utils.toast("图片验证码校验失败");
                        }
                      })
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Form(
        child: Column(
          children: [
            TextField(
              autofocus: false,
              controller: telEtController,
              decoration: InputDecoration(
                labelText: Config.productEnv ? "手机号" : "用户名",
                hintText: Config.productEnv ? "请输入手机号" : "请输入用户名",
                icon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(() {
                  tel = v;
                });
              },
            ),
            Config.productEnv
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: userSigEtController,
                          decoration: InputDecoration(
                            labelText: "验证码",
                            hintText: "请输入验证码",
                            icon: Icon(Icons.lock),
                          ),
                          keyboardType: TextInputType.number,
                          //校验密码
                          onChanged: (v) {
                            setState(() {
                              pwd = v;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 120,
                        child: ElevatedButton(
                          child:
                              isGeted ? Text(timer.toString()) : Text("获取验证码"),
                          onPressed: isGeted
                              ? null
                              : () {
                                  //获取验证码
                                  getLoginCode(context);
                                },
                        ),
                      )
                    ],
                  )
                : Container(),
            Container(
              margin: EdgeInsets.only(
                top: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Colors.grey,
                    ),
                    child: Checkbox(
                      value: checkboxSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          checkboxSelected = value!;
                        });
                      },
                    ),
                  ),
                  Container(
                      child: Expanded(
                          child: Container(
                    child: Text.rich(
                      TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                                text: "我已阅读并同意",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "<<隐私协议>>",
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 110, 253, 1),
                                ),
                                // 设置点击事件
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrivacyAgreementPage(),
                                      ),
                                    );
                                  }),
                            TextSpan(
                                text: "和",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: "<<用户协议>>",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 110, 253, 1),
                              ),
                              // 设置点击事件
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserAgreementPage()));
                                },
                            ),
                            TextSpan(
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
                    ),
                  )))
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 28,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text("登录"),
                      onPressed: !checkboxSelected // 需要隐私协议勾选才可以登陆
                          ? () => unSelectedPrivacy()
                          : () async {
                              print("Confhhh,$tel");
                              if (tel == '') {
                                return;
                              }

                              print(
                                  "Config.productEnv,$tel,${Config.productEnv}");

                              /*  这段代码是当你不需要手机验证码时使用(打包生产)  */
                              /*productEnv这个是为了tencent内部打包时可以直接打包手机验证登陆, 只在登陆方式这里使用，*/
                              if (!Config.productEnv) {
                                // 不时生产环境走，自己测试即不需要手机验证即可登陆
                                print("lllll,${Config.productEnv}");
                                GenerateTestUserSig usersig =
                                    new GenerateTestUserSig(
                                  sdkappid: Config.sdkappid,
                                  key: Config.key,
                                );
                                String pwdStr = usersig.genSig(
                                    identifier: tel, expire: 86400);
                                TencentImSDKPlugin.v2TIMManager
                                    .login(
                                  userID: tel,
                                  userSig: pwdStr,
                                )
                                    .then((res) async {
                                  if (res.code == 0) {
                                    V2TimValueCallback<List<V2TimUserFullInfo>>
                                        infos = await TencentImSDKPlugin
                                            .v2TIMManager
                                            .getUsersInfo(userIDList: [tel]);

                                    if (infos.code == 0) {
                                      Provider.of<UserModel>(context,
                                              listen: false)
                                          .setInfo(infos.data![0]);
                                    }
                                    Future<SharedPreferences> _prefs =
                                        SharedPreferences.getInstance();
                                    SharedPreferences prefs = await _prefs;

                                    prefs.setString("flutter_userID", tel);

                                    // 加个群
                                    await TencentImSDKPlugin.v2TIMManager
                                        .joinGroup(
                                      groupID: "@TGS#2FGN3DHHB",
                                      message: "大家好",
                                    );
                                    Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  } else {
                                    Utils.toast("${res.code} ${res.desc}");
                                  }
                                });
                              } else {
                                // 手机登陆
                                // 获取userSig
                                Dio dio = new Dio();
                                Response response = await dio.get(
                                  "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms",
                                  queryParameters: {
                                    "phone": "86${this.tel}",
                                    "method": "login",
                                    "code": pwd,
                                    "sessionId": sessionId,
                                  },
                                );
                                print(
                                    "pwd:$pwd, phone: $tel, sessionId: $sessionId, response: $response");
                                String userId = '';
                                String userSig = '';
                                String token = '';
                                String avatar = '';
                                try {
                                  userId = response.data['data']['userId'];
                                  userSig = response.data['data']['userSig'];
                                  token = response.data['data']['token'];
                                  avatar = response.data['data']['avatar'];
                                } catch (err) {
                                  Utils.toast(
                                      '${response.data['errorMessage']}(建议重新获取验证码)');
                                }

                                if (response.data['errorCode'] != 0) {
                                  Utils.toast(response.data['errorMessage'] +
                                      "(建议重新获取验证码)");
                                  return;
                                } else {
                                  setState(() {
                                    token = token;
                                  });
                                }
                                var data =
                                    await TencentImSDKPlugin.v2TIMManager.login(
                                  userID: userId,
                                  userSig: userSig,
                                );

                                if (data.code != 0) {
                                  print('登录失败${data.desc}');
                                  return;
                                }

                                // await Tools.setOfflinepush(context);

                                Future<SharedPreferences> _prefs =
                                    SharedPreferences.getInstance();
                                SharedPreferences prefs = await _prefs;
                                prefs.setString("sessionId", sessionId);
                                prefs.setString("token", token);
                                prefs.setString("phone", tel);
                                prefs.setString("code", pwd);
                                V2TimValueCallback<List<V2TimUserFullInfo>>
                                    infos = await TencentImSDKPlugin
                                        .v2TIMManager
                                        .getUsersInfo(userIDList: [userId]);

                                if (infos.code == 0) {
                                  if (infos.data![0].nickName == null ||
                                      infos.data![0].faceUrl == null ||
                                      infos.data![0].nickName == '' ||
                                      infos.data![0].faceUrl == '') {
                                    await TencentImSDKPlugin.v2TIMManager
                                        .setSelfInfo(
                                            userFullInfo:
                                                V2TimUserFullInfo.fromJson({
                                      "nickName": userId,
                                      "faceUrl": avatar,
                                    }));
                                  }
                                  Provider.of<UserModel>(context, listen: false)
                                      .setInfo(infos.data![0]);
                                }
                                setState(() {
                                  tel = '';
                                  pwd = '';
                                  timer = 60;
                                  isGeted = false;
                                });
                              }

                              userSigEtController.clear();
                              telEtController.clear();
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            },
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
