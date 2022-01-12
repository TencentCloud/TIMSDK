import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/config.dart';
import 'package:discuss/pages/check/noConnectivity.dart';
import 'package:discuss/pages/contact/contact.dart';
import 'package:discuss/pages/login/login.dart';
import 'package:discuss/pages/message/message.dart';
import 'package:discuss/pages/search/search.dart';
import 'package:discuss/provider/config.dart';
import 'package:discuss/provider/conversationlistprovider.dart';
import 'package:discuss/provider/friend.dart';
import 'package:discuss/provider/friendapplication.dart';
import 'package:discuss/provider/groupapplication.dart';
import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/provider/user.dart';
import 'package:discuss/utils/GenerateTestUserSig.dart';
import 'package:discuss/utils/imsdk.dart';
import 'package:discuss/utils/offline_push_config.dart';
import 'package:discuss/utils/smslogin.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discuss/pages/contact/choosecontact.dart';
import 'package:discuss/pages/profile/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool hasInit = false;
  var subscription;
  final Connectivity _connectivity = Connectivity();
  @override
  initState() {
    super.initState();
    //监测网络变化
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
    restoreData();
    OfflinePush.init();
    initApp();
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancle();
  }

  restoreData() {
    Provider.of<ConversationListProvider>(context, listen: false)
        .restoreConversation();
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

  /*
      // 如果有本地存的短信登录凭证，直接用凭证登录，如果没有，直接跳转到登录页进行登录
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

        V2TimCallback data = await IMSDK.login(
          userID: userId,
          userSig: userSig,
        );

        if (data.code != 0) {
          Utils.toast("登录失败 ${data.desc}");
          removeLocalSetting();
          directToLogin();
          return;
        }
        getSelfInfo(userId, avatar);
        getIMData();
      } else {
        removeLocalSetting();
        Utils.toast(errorMessage);
      }
    } else {
      directToLogin();
    }
  }
  */

  // 如果有本地存userId，说明之前登陆过
  checkLogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;

    String key = IMDiscussConfig.key;
    int sdkAppId = IMDiscussConfig.sdkappid;
    GenerateTestUserSig generateTestUserSig = GenerateTestUserSig(
      sdkappid: sdkAppId,
      key: key,
    );

    String? userId = prefs.getString("userId");

    Utils.log(" $userId");
    if (userId != null) {
      String userSig =
          generateTestUserSig.genSig(identifier: userId, expire: 99999);

      V2TimCallback data = await IMSDK.login(
        userID: userId,
        userSig: userSig,
      );

      if (data.code != 0) {
        Utils.toast("登录失败 ${data.desc}");
        removeLocalSetting();
        directToLogin();
        return;
      }
      getSelfInfo(userId, null);
      getIMData();
    } else {
      directToLogin();
    }
  }

  getIMData() {
    setOfflinePushInfo();
    getMessage();
    getTatalUnread();
    getGroupApplicationList();
    getFriendList();
    getFriendApplication();
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

  getSelfInfo(userId, String? avatar) async {
    V2TimValueCallback<List<V2TimUserFullInfo>> infos =
        await IMSDK.getUsersInfo(
      userIDList: [userId],
    );
    if (infos.code == 0) {
      if (infos.data![0].nickName == null ||
          infos.data![0].faceUrl == null ||
          infos.data![0].nickName == '' ||
          infos.data![0].faceUrl == '') {
        await IMSDK.setSelfInfo(
          userFullInfo: V2TimUserFullInfo.fromJson(
            {
              "nickName": userId,
              "faceUrl": avatar ?? infos.data![0].faceUrl ?? "",
            },
          ),
        );
      }
      Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
    } else {}
  }

  directToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const LoginPage();
        },
      ),
    );
  }

  getTatalUnread() async {
    V2TimValueCallback<int> res = await IMSDK.getTotalUnreadMessageCount();
    if (res.code == 0) {
      Provider.of<ConversationListProvider>(context, listen: false)
          .updateTotalUnreadCount(res.data!);
    }
  }

  onTotalUnreadMessageCountChanged(int totalunread) {
    Provider.of<ConversationListProvider>(context, listen: false)
        .updateTotalUnreadCount(totalunread);
  }

  onConversationChanged(conversationList) {
    Provider.of<ConversationListProvider>(context, listen: false)
        .conversationItemChange(conversationList);
  }

  onNewConversation(conversationList) {
    Provider.of<ConversationListProvider>(context, listen: false)
        .addNewConversation(conversationList);
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

  onSelfInfoUpdated(info) async {
    Utils.log("个人信息更新 ");
    Provider.of<UserModel>(context, listen: false).setInfo(info);
  }

  onMemberEnter() async {
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.isNotEmpty) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        }
      }
    } else {}
  }

  onReceiveJoinApplication() async {
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.isNotEmpty) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        }
      }
    } else {}
  }

  onFriendApplicationListAdded(List<V2TimFriendApplication> list) {
    // 收到加好友申请,添加双向好友时双方都会周到这个回调，这时要过滤掉type=2的不显示
    List<V2TimFriendApplication> newlist = List.empty(growable: true);
    for (var element in list) {
      if (element.type != 2) {
        newlist.add(element);
      }
    }
    if (newlist.isNotEmpty) {
      Provider.of<FriendApplicationModel>(context, listen: false)
          .setFriendApplicationResult(newlist);
    }
  }

  onBlackListDeleted() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.isNotEmpty) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  onFriendInfoChanged() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.isNotEmpty) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  onFriendListDeleted() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.isNotEmpty) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  onFriendListAdded() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.isNotEmpty) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  onRecvC2CReadReceipt(List<V2TimMessageReceipt> list) {
    for (V2TimMessageReceipt element in list) {
      Provider.of<HistoryMessageListProvider>(context, listen: false)
          .setAllMessageAsRead("c2c_${element.userID}");
    }
  }

  onRecvNewMessage(V2TimMessage message) {
    try {
      List<V2TimMessage> messageList = List.empty(growable: true);

      messageList.add(message);
      String key;
      if (message.groupID == null) {
        key = "c2c_${message.sender}";
      } else {
        key = "group_${message.groupID}";
      }
      Provider.of<HistoryMessageListProvider>(context, listen: false)
          .addMessage(key, messageList);
    } catch (err) {
      Utils.log(err);
    }
  }

  //  发送高级消息才会调用Progress监听回调
  onSendMessageProgress(V2TimMessage message, int progress) {
// 消息进度
    String key;
    if (message.groupID == null) {
      key = "c2c_${message.userID}";
    } else {
      key = "group_${message.groupID}";
    }
    try {
      int imgType = MessageElemType.V2TIM_ELEM_TYPE_IMAGE;
      int soundType = MessageElemType.V2TIM_ELEM_TYPE_SOUND;
      // int videoType = MessageElemType.V2TIM_ELEM_TYPE_VIDEO;
      int fileType = MessageElemType.V2TIM_ELEM_TYPE_FILE;
      var typeArr = [imgType, soundType, fileType];

      // progress回调中必定会回传id(只有progress会带id)
      String id = message.id!;
      String msgId = message.msgID!;
      // 记得覆写id
      message.msgID = id;
      // 文件消息字段处理，增加文件大小
      if (message.elemType == fileType) {
        try {
          String? path = message.fileElem?.path;
          File file = File(path ?? "");
          int size = file.lengthSync();
          message.fileElem?.fileSize = size;
        } catch (err) {
          Utils.log("onSendMessageProgress: FileElem中的path不能为空");
          rethrow;
        }
      }

      if (typeArr.contains(message.elemType)) {
        // TODO: 这个判断是为了暂时解决发送图片时滑动屏幕会导致Provider更新UI冲突临时所添加
        if (progress == 100) {
          message.status = MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC;
        }
        Provider.of<HistoryMessageListProvider>(
          context,
          listen: false,
        ).updateCreateMessage(key, msgId, id, message);
      } else {
        //TODO VideoMessage还没改目前只有老版本用这个
        Provider.of<HistoryMessageListProvider>(
          context,
          listen: false,
        ).updateMessageStatus(
          key,
          message,
        );
      }
    } catch (err) {
      Utils.log("error $err");
    }
    Utils.log(
        "消息发送进度 $progress ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
  }

  initIMSDKAndAddIMListeners() async {
    V2TimValueCallback<bool> init = await IMSDK.init(
      listener: V2TimSDKListener(
        onConnectFailed: (code, error) {},
        onConnectSuccess: () {
          Utils.log("即时通信服务连接成功");
        },
        onConnecting: () {},
        onKickedOffline: () {
          onKickedOffline();
        },
        onSelfInfoUpdated: (info) {
          onSelfInfoUpdated(info);
        },
        onUserSigExpired: () {
          // userSig过期，相当于踢下线
          onKickedOffline();
        },
      ),
    );
    if (init.code != 0 || !init.data!) {
      Utils.toast("即时通信 SDK初始化失败");
    } else {
      IMSDK.setConversationListener(
        listener: V2TimConversationListener(
            onConversationChanged: (conversationList) {
              onConversationChanged(conversationList);
            },
            onNewConversation: (conversationList) {
              onNewConversation(conversationList);
            },
            onSyncServerFailed: () {},
            onSyncServerFinish: () {},
            onSyncServerStart: () {},
            onTotalUnreadMessageCountChanged: (totalunread) {
              onTotalUnreadMessageCountChanged(totalunread);
            }),
      );
      IMSDK.advancedMsgListener(
          listener: V2TimAdvancedMsgListener(
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
      ));
      IMSDK.setFriendListener(
          listener: V2TimFriendshipListener(
        onBlackListAdd: (infoList) {},
        onBlackListDeleted: (userList) {
          onBlackListDeleted();
        },
        onFriendApplicationListAdded: (applicationList) {
          onFriendApplicationListAdded(applicationList);
        },
        onFriendApplicationListDeleted: (userIDList) {},
        onFriendApplicationListRead: () {},
        onFriendInfoChanged: (infoList) {
          onFriendInfoChanged();
        },
        onFriendListAdded: (users) {
          onFriendListAdded();
        },
        onFriendListDeleted: (userList) {
          onFriendListDeleted();
        },
      ));
      IMSDK.setGroupListener(
          listener: V2TimGroupListener(
        onApplicationProcessed: (groupID, opUser, isAgreeJoin, opReason) {},
        onGrantAdministrator: (groupID, opUser, memberList) {},
        onGroupAttributeChanged: (groupID, groupAttributeMap) {},
        onGroupCreated: (groupID) {},
        onGroupDismissed: (groupID, opUser) {},
        onGroupInfoChanged: (groupID, changeInfos) {},
        onGroupRecycled: (groupID, opUser) {},
        onMemberEnter: (groupID, memberList) {
          onMemberEnter();
        },
        onMemberInfoChanged: (groupID, v2TIMGroupMemberChangeInfoList) {},
        onMemberInvited: (groupID, opUser, memberList) {},
        onMemberKicked: (groupID, opUser, memberList) {},
        onMemberLeave: (groupID, member) {},
        onQuitFromGroup: (groupID) {},
        onReceiveJoinApplication: (groupID, member, opReason) {
          onReceiveJoinApplication();
        },
        onReceiveRESTCustomData: (groupID, customData) {},
        onRevokeAdministrator: (groupID, opUser, memberList) {},
      ));
      setState(() {
        hasInit = true;
      });
    }
  }

  Map<int, String> pageTitle = {
    0: "腾讯·云通信",
    1: "消息",
    2: "账号",
    3: "我",
  };
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
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.isNotEmpty) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        } else {
          List<V2TimGroupApplication> list = List.empty(growable: true);
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(list);
        }
      }
    } else {
      Utils.log("获取加群申请失败${res.desc}");
    }
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

  static List<NavigationBarData> getBottomNavigatorList() {
    List<NavigationBarData> list = [];
    List<NavigationBarData> bottomNavigatorList = [
      NavigationBarData(
        widget: const Message(),
        // widget: Text("1"),
        title: "消息",
        selectedIcon: Icon(
          Icons.message,
          color: hexToColor("4f98f9"),
        ),
        unselectedIcon: const Icon(
          Icons.message,
          color: Colors.grey,
        ),
      ),
      NavigationBarData(
        widget: const Contact(),
        title: "通讯录",
        selectedIcon: Icon(
          Icons.supervised_user_circle,
          color: hexToColor("4f98f9"),
        ),
        unselectedIcon: const Icon(
          Icons.supervised_user_circle,
          color: Colors.grey,
        ),
      ),
      NavigationBarData(
        widget: const Profile(),
        title: "账号",
        selectedIcon: Icon(
          Icons.perm_identity,
          color: hexToColor("4f98f9"),
        ),
        unselectedIcon: const Icon(
          Icons.perm_identity,
          color: Colors.grey,
        ),
      ),
    ];

    for (var item in bottomNavigatorList) {
      list.add(item);
    }

    return list;
  }

  final List<NavigationBarData> bottomNavigatorList = getBottomNavigatorList();

  /// 当前选择下标
  int currentIndex = 0;

  ///关闭
  close() {
    Navigator.of(context).pop();
  }

  //如果点击的导航页不是当前项，切换
  void _changePage(int index) {
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  Widget? getTitle() {
    return Text(
      pageTitle[currentIndex]!,
      style: const TextStyle(
          color: Colors.black, fontSize: IMDiscussConfig.appBarTitleFontSize),
    );
  }

  List messageActionList = [
    {
      'name': '发起会话',
      'type': 1,
    },
    {
      'name': '创建好友工作群(Work)',
      'type': 2,
    },
    {
      'name': '创建陌生人社交群(Public)',
      'type': 3,
    },
    {
      'name': '创建临时会议群(Meeting)',
      'type': 4,
    },
    {
      'name': '创建直播群(AVChatRoom)',
      'type': 5,
    },
  ];
  List concatActionList = [
    {
      'name': '添加好友',
      'type': 1,
    },
    {
      'name': '加入群组',
      'type': 2,
    },
  ];
  chooseContact(int type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseContact(type, null),
      ),
    );
  }

  openAddPage(int type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Search(type),
      ),
    );
  }

  messagePopUpMenu(ctx) {
    return showCupertinoModalPopup<String>(
      context: ctx,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: null,
          actions: messageActionList
              .map(
                (e) => CupertinoActionSheetAction(
                  onPressed: () {
                    chooseContact(e['type']);
                  },
                  child: Text(e['name']),
                  isDefaultAction: false,
                ),
              )
              .toList(),
        );
      },
    );
  }

  concatPopUpMenu(ctx) {
    return showCupertinoModalPopup<String>(
      context: ctx,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: null,
          actions: concatActionList
              .map(
                (e) => CupertinoActionSheetAction(
                  onPressed: () {
                    openAddPage(e['type']);
                  },
                  child: Text(e['name']),
                  isDefaultAction: false,
                ),
              )
              .toList(),
        );
      },
    );
  }

  List<Widget>? getAction(context) {
    return <Widget>[
      // if (currentIndex == 1)
      //   IconButton(
      //     onPressed: () {
      //       messagePopUpMenu(context);
      //     },
      //     icon: const Icon(
      //       Icons.add,
      //       color: Colors.black,
      //     ),
      //   ),
      currentIndex == 2
          ? IconButton(
              onPressed: () {
                concatPopUpMenu(context);
              },
              icon: const Icon(Icons.add),
            )
          : Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // int unreadCount =
    //     Provider.of<ConversationListProvider>(context).totalUnreadCount;
    // String unreadDisplay = "";
    // if (unreadCount > 0) {
    //   if (unreadCount > 99) {
    //     unreadDisplay = '...';
    //   } else {
    //     unreadDisplay = unreadCount.toString();
    //   }
    // }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: null,
        backgroundColor: CommonColors.getThemeColor(),
        title: getTitle(),
        centerTitle: true,
        actions: getAction(context),
      ),

      body: IndexedStack(
        index: currentIndex,
        children: hasInit
            ? bottomNavigatorList.map((res) => res.widget).toList()
            : [],
      ),
      // bottomNavigationBar: ConvexAppBar.badge(
      //   {
      //     0: unreadDisplay,
      //   },
      //   backgroundColor: CommonColors.getThemeColor(),
      //   badgeMargin: const EdgeInsets.fromLTRB(30, 0, 0, 32),
      //   style: TabStyle.textIn,
      //   items: List.generate(
      //     bottomNavigatorList.length,
      //     (index) => TabItem(
      //       icon: index == currentIndex
      //           ? bottomNavigatorList[index].selectedIcon
      //           : bottomNavigatorList[index].unselectedIcon,
      //       title: bottomNavigatorList[index].title,
      //     ),
      //   ),
      //   initialActiveIndex: currentIndex,
      //   onTap: (int index) {
      //     _changePage(index);
      //   },
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: List.generate(
          bottomNavigatorList.length,
          (index) => BottomNavigationBarItem(
            icon: index == currentIndex
                ? bottomNavigatorList[index].selectedIcon
                : bottomNavigatorList[index].unselectedIcon,
            label: bottomNavigatorList[index].title,
          ),
        ),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _changePage(index);
        },
        selectedItemColor: hexToColor('006fff'),
        unselectedItemColor: Colors.grey,
        backgroundColor: hexToColor("EBF0F6"),
      ),
    );
  }
}

/// 底部导航栏数据对象
class NavigationBarData {
  /// 未选择时候的图标
  final Widget unselectedIcon;

  /// 选择后的图标
  final Widget selectedIcon;

  /// 标题内容
  final String title;

  /// 页面组件
  final Widget widget;

  NavigationBarData({
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.title,
    required this.widget,
  });
}
