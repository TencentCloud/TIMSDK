import 'dart:async';

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_tips_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/V2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_status.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/event_enum.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/message_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_add_friend.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_create_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_friend_black_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_friend_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_init_sdk.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_login.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_profile.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';
import 'dart:js_util';

import '../enum/group_receive_message_opt.dart';
import '../models/v2_tim_get_conversation_list.dart';
import 'im_sdk_plugin_js.dart';

class V2TIMManager {
  static late TIM tim;
  static late V2TimSimpleMsgListener simpleMsglistener;
  static V2TimGroupListener? groupListener;
  static late String userID = "";
  // 多加一个init 为了保证在web SDKReady前调用不会被执行（磨平差异）
  static List<dynamic> friendList = ["init"];
  static List<dynamic> blackList = ["init"];
  static List<dynamic> friendApplicationList = ["init"];

  static void updateBlackList(List<dynamic> list) {
    blackList = list;
  }

  static void updtateFriendList(List<dynamic> list) {
    friendList = list;
  }

  static void updateFriendApplicationList(List<dynamic> list) {
    friendApplicationList = list;
  }

  static List<dynamic> getFriendList() {
    return friendList;
  }

  static List<dynamic> getBlackList() {
    return blackList;
  }

  static List<dynamic> getFriendApplicationList() {
    return friendApplicationList;
  }

  static String getUserID() {
    return userID;
  }

  static initFriendList() async {
    final res =
        await wrappedPromiseToFuture(V2TIMManagerWeb.timWeb!.getFriendList());
    if (res.code == 0) {
      friendList = FriendList.formatedFriendListRes(res.data);
    }
  }

  static initBlackList() async {
    final res =
        await wrappedPromiseToFuture(V2TIMManagerWeb.timWeb!.getBlacklist());
    if (res.code == 0) {
      blackList = FriendBlackList.formateBlackList(res.data);
    }
  }

  static initFriendApplicationList() async {
    final res = await wrappedPromiseToFuture(
        V2TIMManagerWeb.timWeb!.getFriendApplicationList());
    if (res.code == 0) {
      friendApplicationList = FriendApplication.formateResult(
          jsToMap(res.data))["friendApplicationList"];
    }
  }

  // web：创建实例，统一接口为init
  V2TimValueCallback<bool> initSDK(
      {required int sdkAppID, V2TimSDKListener? listener}) {
    TimParams timParams = TimParams();
    timParams.SDKAppID = sdkAppID;
    V2TIMManagerWeb.initWebTim(timParams);
    // 初始化各个List
    V2TIMManagerWeb.timWeb!.on(EventType.SDK_READY, allowInterop((res) {
      initFriendList();
      initBlackList();
      initFriendApplicationList();
      listener!.onConnectSuccess();
    }));

    V2TIMManagerWeb.timWeb!.on(EventType.KICKED_OUT, allowInterop((res) {
      listener!.onKickedOffline();
    }));

    return CommonUtils.returnSuccess<bool>(true);
  }

  // unIntitSDK会自动登出
  Future<dynamic> unInitSDK() async {
    if (V2TIMManagerWeb.timWeb != null) {
      try {
        await promiseToFuture(V2TIMManagerWeb.timWeb!.destroy());
        userID = "";
        return CommonUtils.returnSuccess<String>("uninit success");
      } catch (err) {
        return CommonUtils.returnError(jsToMap(err));
      }
    }
    return CommonUtils.returnError("未初始化");
  }

  Future<V2TimCallback> login(
      {required String userID, required String userSig}) async {
    try {
      LoginParams loginParams = LoginParams()
        ..userID = userID
        ..userSig = userSig;
      final resLogin = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.login(loginParams));
      if (resLogin.code == 0) {
        userID = loginParams.userID;

        return CommonUtils.returnSuccessWithDesc('login success');
      }

      return CommonUtils.returnSuccessWithDesc('login failed');
    } catch (err) {
      return CommonUtils.returnError(err);
    }
  }

  Future<dynamic> logout() async {
    try {
      final res =
          await wrappedPromiseToFuture(V2TIMManagerWeb.timWeb!.logout());
      final code = res.code;
      if (code == 0) {
        return CommonUtils.returnSuccessWithDesc("logout success");
      } else {
        return CommonUtils.returnSuccessWithDesc("logout failed");
      }
    } catch (err) {
      return CommonUtils.returnError(err);
    }
  }

  Future<dynamic> getLoginUser() async {
    try {
      final userProfile =
          await wrappedPromiseToFuture(V2TIMManagerWeb.timWeb!.getMyProfile());
      final code = userProfile.code;
      final profile = jsToMap(userProfile.data);
      if (code == 0) {
        return CommonUtils.returnSuccess<String>(profile["userID"]);
      } else {
        return CommonUtils.returnError('获取失败!');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> getLoginStatus() async {
    return CommonUtils.returnErrorForValueCb<int>('Not support for web');
  }

  Future<dynamic> getVersion() async {
    final version = V2TIMManagerWeb.getWebSDKVersion();
    return CommonUtils.returnSuccess<String>(version);
  }

  Future<V2TimValueCallback<int>> getServerTime() async {
    return CommonUtils.returnSuccess(null, desc: "No support for web");
  }

  Future<dynamic> quitGroup(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.quitGroup(params['groupID']));
      final code = res.code;
      if (code == 0) {
        return CommonUtils.returnSuccessWithDesc("ok");
      } else {
        return CommonUtils.returnError('退群失败');
      }
    } catch (err) {
      return CommonUtils.returnError(err);
    }
  }

  Future<V2TimCallback> dismissGroup(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.dismissGroup(params['groupID']));
      final code = res.code;
      if (code == 0) {
        return CommonUtils.returnSuccessWithDesc("ok");
      } else {
        return CommonUtils.returnError('解散群败');
      }
    } catch (err) {
      return CommonUtils.returnError(err);
    }
  }

  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo(
      Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.getUserProfile(mapToJSObj(params)));
      final code = res.code;
      if (code == 0) {
        final userListInfo = res.data as List;
        final userListResult = List.empty(growable: true);
        for (var element in userListInfo) {
          userListResult
              .add(V2TimProfile.userFullInfoExtract(jsToMap(element)));
        }
        return CommonUtils.returnSuccess<List<V2TimUserFullInfo>>(
            userListResult);
      }
      return CommonUtils.returnSuccess<List<V2TimUserFullInfo>>(List.empty());
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimUserFullInfo>>(
          error.toString());
    }
  }

  Future<dynamic> setSelfInfo(Map<String, dynamic> params) async {
    try {
      final formatedParams = V2TimProfile.formateSetSelfInfoParams(params);
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.updateMyProfile(formatedParams));
      final code = res.code;
      if (code == 0) {
        return CommonUtils.returnSuccessWithDesc("ok");
      } else {
        return CommonUtils.returnError('设置个人信息出错:$code');
      }
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage(
      Map<String, dynamic> params) async {
    try {
      final textParams = CreateMessage.createTextMessage(
          userID: params['userID'], text: params['text']);
      final textMessage = V2TIMManagerWeb.timWeb!.createTextMessage(textParams);
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.sendMessage(textMessage));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)["message"];
        log(message);
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>("发送文本消息失败");
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error.toString());
    }
  }

  Future<dynamic> sendC2CCustomMessage(Map<String, dynamic> params) async {
    try {
      final customParams = CreateMessage.createCustomMessage(
          userID: params['userID'], customData: params['customData']);
      final customMessage =
          V2TIMManagerWeb.timWeb!.createCustomMessage(customParams);
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.sendMessage(customMessage));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>('发送自定义消息失败');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error.toString());
    }
  }

  Future<dynamic> sendGroupTextMessage(Map<String, dynamic> params) async {
    try {
      final textParams = CreateMessage.createTextMessage(
          userID: params['groupID'],
          text: params['text'],
          convType: 'GROUP',
          priority: params['priority']);
      final textMessage = V2TIMManagerWeb.timWeb!.createTextMessage(textParams);
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.sendMessage(textMessage));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)["message"];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>('发送群文本消息失败');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error.toString());
    }
  }

  Future<dynamic> sendGroupCustomMessage(Map<String, dynamic> params) async {
    try {
      final customParams = CreateMessage.createCustomMessage(
          userID: params['groupID'],
          customData: params['customData'],
          convType: 'GROUP',
          priority: params['priority']);
      final textMessage =
          V2TIMManagerWeb.timWeb!.createCustomMessage(customParams);
      final res = await wrappedPromiseToFuture(
          V2TIMManagerWeb.timWeb!.sendMessage(textMessage));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)["message"];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>('发送群文本消息失败');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error.toString());
    }
  }

  Future<dynamic> callExperimentalAPI() async {
    return CommonUtils.returnErrorForValueCb<Object>('Not support for web');
  }

  void addSimpleMsgListener(
    V2TimSimpleMsgListener listener,
  ) {
    simpleMsglistener = listener;
    submitOnReciveMessageListiner();
  }

  void removeSimpleMsgListener() {
    V2TIMManagerWeb.timWeb
        ?.off(EventType.MESSAGE_RECEIVED, _reciveMessageHandler);
  }

  void setGroupListener(V2TimGroupListener listener) {
    groupListener = listener;
    submitGroupAttributeChanged();
    submitGroupInfoChangded();
    submitTopicChanged();
  }

  void removeGroupListener() {
    V2TIMManagerWeb.timWeb
        ?.off(EventType.GROUP_ATTRIBUTES_UPDATED, _groupAttributeChangeHandler);
    V2TIMManagerWeb.timWeb
        ?.off(EventType.MESSAGE_RECEIVED, _groupInfoChanageHandler);
    V2TIMManagerWeb.timWeb?.off(EventType.TOPIC_CREATED, _topicCreateHandler);
    V2TIMManagerWeb.timWeb?.off(EventType.TOPIC_DELETED, _topicDeletedHandler);
    V2TIMManagerWeb.timWeb?.off(EventType.TOPIC_UPDATED, _topicUpdateHandler);
  }

  static final _topicCreateHandler = allowInterop((dynamic res) {
    final reponse = jsToMap(res);
    groupListener?.onTopicCreated(jsToMap(reponse['data'])['groupID'],
        jsToMap(reponse['data'])['topicID']);
  });

  static final _topicUpdateHandler = allowInterop((dynamic res) async {
    final topicInfo = jsToMap(jsToMap(res.data)['topic']);
    final formatedMessage = await GetConversationList.formateLasteMessage(
        jsToMap(topicInfo["lastMessage"]));
    final formatedTopicInfo = V2TimTopicInfo.fromJson({
      "topicID": topicInfo["topicID"],
      "topicName": topicInfo["topicName"],
      "topicFaceUrl": topicInfo["avatar"],
      "introduction": topicInfo["introduction"],
      "notification": topicInfo["notification"],
      "isAllMute": topicInfo["muteAllMembers"],
      "selfMuteTime": jsToMap(topicInfo["selfInfo"])["muteTime"],
      "customString": topicInfo["customData"],
      "recvOpt": GroupRecvMsgOpt.convertMsgRecvOpt(
          jsToMap(topicInfo["selfInfo"])["messageRemindType"]),
      "unreadCount": topicInfo["unreadCount"],
      "lastMessage": formatedMessage,
      "groupAtInfoList": GetConversationList.formateGroupAtInfoList(
          topicInfo["groupAtInfoList"])
    });
    groupListener?.onTopicInfoChanged(
        jsToMap(res.data)['groupID'], formatedTopicInfo);
  });

  static final _topicDeletedHandler = allowInterop((dynamic res) {
    final groupID = jsToMap(res.data)['groupID'] as String;
    final topicIDList = jsToMap(res.data)['topicIDList'] as List;
    groupListener?.onTopicDeleted(
        groupID, topicIDList.map((e) => e as String).toList());
  });

  static void submitTopicChanged() {
    V2TIMManagerWeb.timWeb?.on(EventType.TOPIC_CREATED, _topicCreateHandler);

    V2TIMManagerWeb.timWeb?.on(EventType.TOPIC_DELETED, _topicDeletedHandler);

    V2TIMManagerWeb.timWeb?.on(EventType.TOPIC_UPDATED, _topicUpdateHandler);
  }

  static final _groupAttributeChangeHandler = allowInterop((dynamic res) {
    final reponse = jsToMap(res);
    final responseData = jsToMap(reponse['data']);
    final attributes = responseData['groupAttributes'];
    final groupID = responseData['groupID'];
    final Map<String, String> groupAttributeMap =
        jsToMap(attributes) as Map<String, String>;

    groupListener?.onGroupAttributeChanged(groupID, groupAttributeMap);
  });

  static void submitGroupAttributeChanged() {
    V2TIMManagerWeb.timWeb
        ?.on(EventType.GROUP_ATTRIBUTES_UPDATED, _groupAttributeChangeHandler);
  }

  static final _groupInfoChanageHandler = allowInterop((dynamic response) {
    final List message = jsToMap(response)["data"];
    for (var item in message) {
      final formatedItem = jsToMap(item);
      // 处理群提示消息
      loop() async {
        if (formatedItem['type'] == MsgType.MSG_GRP_TIP) {
          final tipsMessageElement =
              await V2TIMMessage.convertGroupTipsMessage(formatedItem);
          final groupID = tipsMessageElement?.groupID;
          if (groupID == null) {
            return;
          }
          final type = tipsMessageElement?.type;
          if (type ==
              GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE) {
            final changeInfoList = tipsMessageElement?.groupChangeInfoList
                as List<V2TimGroupChangeInfo>;
            groupListener?.onGroupInfoChanged(groupID, changeInfoList);
          }

          if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE) {
            final memberList =
                tipsMessageElement?.memberList as List<V2TimGroupMemberInfo>;
            final opUser = tipsMessageElement?.opMember;
            groupListener?.onMemberInvited(groupID, opUser!, memberList);
          }

          if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN) {
            final memberList =
                tipsMessageElement?.memberList as List<V2TimGroupMemberInfo>;
            groupListener?.onMemberEnter(groupID, memberList);
          }

          if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_KICKED) {
            final memberList =
                tipsMessageElement?.memberList as List<V2TimGroupMemberInfo>;
            final opUser = tipsMessageElement?.opMember;
            groupListener?.onMemberKicked(groupID, opUser!, memberList);
          }

          if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT) {
            final memberList =
                tipsMessageElement?.memberList as V2TimGroupMemberInfo;
            groupListener?.onMemberLeave(groupID, memberList);
          }

          if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN) {
            final memberList =
                tipsMessageElement?.memberList as List<V2TimGroupMemberInfo>;
            final opUser = tipsMessageElement?.opMember;
            groupListener?.onGrantAdministrator(groupID, opUser!, memberList);
          }

          if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN) {
            final memberList =
                tipsMessageElement?.memberList as List<V2TimGroupMemberInfo>;
            final opUser = tipsMessageElement?.opMember;
            groupListener?.onRevokeAdministrator(groupID, opUser!, memberList);
          }

          if (type ==
              GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE) {
            final memberChangeInfoList = tipsMessageElement
                ?.memberChangeInfoList as List<V2TimGroupMemberChangeInfo>;
            groupListener?.onMemberInfoChanged(groupID, memberChangeInfoList);
          }
        }

        // 群系统提示消息
        if (formatedItem['type'] == MsgType.MSG_GRP_SYS_NOTICE) {
          final formatedGroupNoticeMsg =
              await V2TIMMessage.convertGroupNoticeMessage(formatedItem);
          final listinerName = formatedGroupNoticeMsg!.listennerName;
          final groupID = formatedGroupNoticeMsg.groupID;
          final opUser = formatedGroupNoticeMsg.opUser;
          final opReason = formatedGroupNoticeMsg.opReason;
          final customData = formatedGroupNoticeMsg.customData;
          final isAgreeJoin = formatedGroupNoticeMsg.isAgreeJoin;
          if (listinerName == 'onReceiveJoinApplication') {
            groupListener?.onReceiveJoinApplication(groupID, opUser, opReason);
          }
          if (listinerName == 'onApplicationProcessed') {
            groupListener?.onApplicationProcessed(
                groupID, opUser, isAgreeJoin, opReason);
          }
          if (listinerName == 'onGroupDismissed') {
            groupListener?.onGroupDismissed(groupID, opUser);
          }
          if (listinerName == 'onGroupCreated') {
            groupListener?.onGroupCreated(groupID);
          }
          if (listinerName == 'onGroupRecycled') {
            groupListener?.onGroupRecycled(groupID, opUser);
          }
          if (listinerName == 'onReceiveRESTCustomData') {
            groupListener?.onReceiveRESTCustomData(groupID, customData);
          }
        }
      }

      loop();
    }
  });

  static void submitGroupInfoChangded() {
    V2TIMManagerWeb.timWeb
        ?.on(EventType.MESSAGE_RECEIVED, _groupInfoChanageHandler);
  }

  static final _reciveMessageHandler = allowInterop((dynamic responseData) {
    final response = jsToMap(responseData);
    final List reciveMessageList = response['data'];
    for (var messageItem in reciveMessageList) {
      final messageItemMap = jsToMap(messageItem);
      final messagePayloadMap = jsToMap(messageItemMap['payload']);
      final reciveMessageType =
          V2TIMMessage.getReciveMessageType(messageItemMap);
      if (reciveMessageType == 'onRecvC2CTextMessage') {
        final String messageID = messageItemMap['ID'];
        final senderUserInfo = V2TimUserInfo(
            userID: messageItemMap['from'],
            nickName: messageItemMap['nick'],
            faceUrl: messageItemMap['avatar']);
        final String text = messagePayloadMap['text'];
        simpleMsglistener.onRecvC2CTextMessage(messageID, senderUserInfo, text);
      }
      if (reciveMessageType == 'onRecvGroupTextMessage') {
        final String messageID = messageItemMap['ID'];
        final senderUserInfo = V2TimGroupMemberInfo(
            userID: messageItemMap['from'],
            nickName: messageItemMap['nick'],
            friendRemark: '',
            faceUrl: messageItemMap['avatar'],
            nameCard: messageItemMap['nameCard']);
        final String text = messagePayloadMap['text'];
        final String groupID = messageItemMap['to'];
        simpleMsglistener.onRecvGroupTextMessage(
            messageID, groupID, senderUserInfo, text);
      }

      if (reciveMessageType == 'onRecvC2CCustomMessage') {
        final String messageID = messageItemMap['ID'];
        final senderUserInfo = V2TimUserInfo(
            userID: messageItemMap['from'],
            nickName: messageItemMap['nick'],
            faceUrl: messageItemMap['avatar']);
        final String customData = messagePayloadMap['data'];
        simpleMsglistener.onRecvC2CCustomMessage(
            messageID, senderUserInfo, customData);
      }

      if (reciveMessageType == 'onRecvGroupCustomMessage') {
        final String messageID = messageItemMap['ID'];
        final senderUserInfo = V2TimGroupMemberInfo(
            userID: messageItemMap['from'],
            nickName: messageItemMap['nick'],
            friendRemark: '',
            faceUrl: messageItemMap['avatar'],
            nameCard: messageItemMap['nameCard']);
        final String customData = messagePayloadMap['data'];
        final String groupID = messageItemMap['to'];
        simpleMsglistener.onRecvGroupCustomMessage(
            messageID, groupID, senderUserInfo, customData);
      }
    }
  });

  static void submitOnReciveMessageListiner() {
    V2TIMManagerWeb.timWeb
        ?.on(EventType.MESSAGE_RECEIVED, _reciveMessageHandler);
  }

  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) async {
    try {
      final res = await wrappedPromiseToFuture(V2TIMManagerWeb.timWeb!
          .getUserStatus(mapToJSObj({"userIDList": userIDList})));
      final code = res.code;
      if (code == 0) {
        final successUserList = jsToMap(res.data)["successUserList"] as List;
        // final failureUserList = jsToMap(res.data)["failureUserList"];
        final formatedUserList = successUserList.map((e) {
          final item = jsToMap(e);
          return {
            "userID": item["userID"],
            "statusType": item["statusType"],
            "customStatus": item["customStatus"]
          };
        }).toList();

        return CommonUtils.returnSuccess<List<V2TimUserStatus>>(
            formatedUserList);
      } else {
        return CommonUtils.returnErrorForValueCb<List<V2TimUserStatus>>(
            'getUserStatus failed');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimUserStatus>>(
          error.toString());
    }
  }
}
