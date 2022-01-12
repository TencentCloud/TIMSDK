import 'dart:convert';

import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/listener_type.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/utils.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_conversation_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_friendship_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_group_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_message_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_offline_push_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_signaling_manager.dart';
import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_user_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:uuid/uuid.dart';

/// IM SDK 主核心类，负责 IM SDK 的初始化、登录、消息收发，建群退群等功能。
///
///[initSDK] 初始化 SDK
///
///[unInitSDK] 反初始化 SDK
///
///[login] 登录
///
///[logout] 登出
///
///[getLoginUser] 获取登录用户
///
///[getLoginStatus] 获取登录状态
///
///[addSimpleMsgListener] 设置基本消息（文本消息和自定义消息）的事件监听器
///
///[removeSimpleMsgListener] 移除基本消息（文本消息和自定义消息）的事件监听器
///
///[sendC2CTextMessage] 发送单聊普通文本消息（最大支持 8KB）
///
///[sendC2CCustomMessage] 发送单聊自定义（信令）消息（最大支持 8KB）
///
///[sendGroupTextMessage] 发送群聊普通文本消息（最大支持 8KB）
///
///[sendGroupCustomMessage] 发送群聊自定义（信令）消息（最大支持 8KB）
///
///[setGroupListener] 设置群组监听器
///
///[createGroup] 创建群组（已弃用）
///
///[joinGroup] 加入群组
///
///[quitGroup] 退出群组
///
///{@category Manager}
///
class V2TIMManager {
  ///@nodoc
  late MethodChannel _channel;

  ///@nodoc
  late V2TIMConversationManager v2ConversationManager;

  ///@nodoc
  late V2TIMMessageManager v2TIMMessageManager;

  ///@nodoc
  late V2TIMFriendshipManager v2TIMFriendshipManager;

  ///@nodoc
  late V2TIMGroupManager v2TIMGroupManager;

  ///@nodoc
  late V2TIMOfflinePushManager v2TIMOfflinePushManager;

  ///@nodoc
  late V2TIMSignalingManager v2timSignalingManager;

  late Map<String, V2TimSimpleMsgListener> simpleMessageListenerList = {};

  late Map<String, V2TimSDKListener> initSDKListenerList = {};

  late Map<String, V2TimGroupListener> groupListenerList = {};

  ///@nodoc
  V2TIMManager(MethodChannel channel) {
    this._channel = channel;
    this.v2ConversationManager = new V2TIMConversationManager(channel);
    this.v2TIMMessageManager = new V2TIMMessageManager(channel);
    this.v2TIMFriendshipManager = new V2TIMFriendshipManager(channel);
    this.v2TIMGroupManager = new V2TIMGroupManager(channel);
    this.v2TIMOfflinePushManager = new V2TIMOfflinePushManager(channel);
    this.v2timSignalingManager = new V2TIMSignalingManager(channel);
    this.addNativeCallback(channel);
  }

  _catchListenerError(Function listener) {
    try {
      listener();
    } catch (err, errorStack) {
      print("$err $errorStack");
    }
  }

  ///@nodoc
  void addNativeCallback(MethodChannel _channel) {
    _channel.setMethodCallHandler((call) {
      try {
        if (call.method == ListenerType.simpleMsgListener) {
          Map<String, dynamic> data = this.formatJson(call.arguments);
          String listenerUuid = data['listenerUuid'];
          V2TimSimpleMsgListener? simpleMsgListener =
              this.simpleMessageListenerList[listenerUuid];
          Map<String, dynamic> params =
              data['data'] == null ? new Map<String, dynamic>() : data['data'];
          String type = data['type'];
          if (simpleMsgListener != null) {
            final msgID = params['msgID'];
            switch (type) {
              case 'onRecvC2CCustomMessage':
                // String msgID, V2TIMUserInfo sender, byte[] customData
                final sender = V2TimUserInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  simpleMsgListener.onRecvC2CCustomMessage(
                    msgID,
                    sender,
                    params['customData'],
                  );
                });
                break;
              case 'onRecvC2CTextMessage':
                // String msgID, V2TIMUserInfo sender, String text
                final sender = V2TimUserInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  simpleMsgListener.onRecvC2CTextMessage(
                    msgID,
                    sender,
                    params['text'],
                  );
                });
                break;
              case 'onRecvGroupCustomMessage':
                // String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData
                final groupSender =
                    V2TimGroupMemberInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  simpleMsgListener.onRecvGroupCustomMessage(
                    msgID,
                    params['groupID'],
                    groupSender,
                    params['customData'],
                  );
                });
                break;
              case 'onRecvGroupTextMessage':
                // String msgID, String groupID, V2TIMGroupMemberInfo sender, String text
                final groupSender =
                    V2TimGroupMemberInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  simpleMsgListener.onRecvGroupTextMessage(
                    params['msgID'],
                    params['groupID'],
                    groupSender,
                    params['text'],
                  );
                });
                break;
            }
          }
        } else if (call.method == ListenerType.initSDKListener) {
          Map<String, dynamic> data = this.formatJson(call.arguments);
          String listenerUuid = data['listenerUuid'];
          V2TimSDKListener? initSDKListener =
              this.initSDKListenerList[listenerUuid];
          Map<String, dynamic> params =
              data['data'] == null ? new Map<String, dynamic>() : data['data'];
          String type = data['type'];
          if (initSDKListener != null) {
            switch (type) {
              case 'onSelfInfoUpdated':
                final userInfo = V2TimUserFullInfo.fromJson(params);
                _catchListenerError(() {
                  initSDKListener.onSelfInfoUpdated(userInfo);
                });
                break;
              case 'onConnectFailed':
                _catchListenerError(() {
                  initSDKListener.onConnectFailed(
                    params['code'],
                    params['desc'],
                  );
                });
                break;
              case 'onConnecting':
                _catchListenerError(() {
                  initSDKListener.onConnecting();
                });
                break;
              case 'onConnectSuccess':
                _catchListenerError(() {
                  initSDKListener.onConnectSuccess();
                });
                break;
              case 'onKickedOffline':
                _catchListenerError(() {
                  initSDKListener.onKickedOffline();
                });
                break;
              case 'onUserSigExpired':
                _catchListenerError(() {
                  initSDKListener.onUserSigExpired();
                });
                break;
            }
          }
        } else if (call.method == ListenerType.groupListener) {
          Map<String, dynamic> data = this.formatJson(call.arguments);
          String listenerUuid = data['listenerUuid'];
          V2TimGroupListener? groupListener =
              this.groupListenerList[listenerUuid];
          String type = data['type'];
          Map<String, dynamic> params = data['data'] == null
              ? new Map<String, dynamic>()
              : new Map<String, dynamic>.from(data['data']);

          String groupID = params['groupID'] == null ? '' : params['groupID'];
          String opReason =
              params['opReason'] == null ? '' : params['opReason'];
          bool isAgreeJoin =
              params['isAgreeJoin'] == null ? false : params['isAgreeJoin'];
          String customData =
              params['customData'] == null ? '' : params['customData'];

          Map<String, String> groupAttributeMap =
              params['groupAttributeMap'] == null
                  ? new Map<String, String>()
                  : new Map<String, String>.from(params['groupAttributeMap']);

          List<Map<String, dynamic>> memberListMap =
              params['memberList'] == null
                  ? List.empty(growable: true)
                  : List.from(params['memberList']);

          List<Map<String, dynamic>> groupMemberChangeInfoListMap =
              params['groupMemberChangeInfoList'] == null
                  ? List.empty(growable: true)
                  : List.from(params['groupMemberChangeInfoList']);

          List<Map<String, dynamic>> groupChangeInfoListMap =
              params['groupChangeInfoList'] == null
                  ? List.empty(growable: true)
                  : List.from(params['groupChangeInfoList']);
          List<V2TimGroupChangeInfo> groupChangeInfoList =
              List.empty(growable: true);
          List<V2TimGroupMemberChangeInfo> groupMemberChangeInfoList =
              List.empty(growable: true);
          List<V2TimGroupMemberInfo> memberList = List.empty(growable: true);

          if (memberListMap.isNotEmpty) {
            memberListMap.forEach((element) {
              memberList.add(V2TimGroupMemberInfo.fromJson(element));
            });
          }
          if (groupMemberChangeInfoListMap.isNotEmpty) {
            groupMemberChangeInfoListMap.forEach((element) {
              groupMemberChangeInfoList
                  .add(V2TimGroupMemberChangeInfo.fromJson(element));
            });
          }
          if (groupChangeInfoListMap.isNotEmpty) {
            groupChangeInfoListMap.forEach((element) {
              groupChangeInfoList.add(V2TimGroupChangeInfo.fromJson(element));
            });
          }
          late V2TimGroupMemberInfo opUser;
          late V2TimGroupMemberInfo member;
          if (params['opUser'] != null) {
            opUser = V2TimGroupMemberInfo.fromJson(params['opUser']);
          }
          if (params['member'] != null) {
            member = V2TimGroupMemberInfo.fromJson(params['member']);
          }
          if (groupListener != null) {
            switch (type) {
              case 'onMemberEnter':
                _catchListenerError(() {
                  groupListener.onMemberEnter(
                    groupID,
                    memberList,
                  );
                });
                break;
              case 'onMemberLeave':
                _catchListenerError(() {
                  groupListener.onMemberLeave(
                    groupID,
                    member,
                  );
                });
                break;
              case 'onMemberInvited':
                _catchListenerError(() {
                  groupListener.onMemberInvited(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                break;
              case 'onMemberKicked':
                _catchListenerError(() {
                  groupListener.onMemberKicked(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                break;
              case 'onMemberInfoChanged':
                _catchListenerError(() {
                  groupListener.onMemberInfoChanged(
                    groupID,
                    groupMemberChangeInfoList,
                  );
                });
                break;
              case 'onGroupCreated':
                _catchListenerError(() {
                  groupListener.onGroupCreated(groupID);
                });
                break;
              case 'onGroupDismissed':
                _catchListenerError(() {
                  groupListener.onGroupDismissed(
                    groupID,
                    opUser,
                  );
                });
                break;
              case 'onGroupRecycled':
                _catchListenerError(() {
                  groupListener.onGroupRecycled(
                    groupID,
                    opUser,
                  );
                });
                break;
              case 'onGroupInfoChanged':
                _catchListenerError(() {
                  groupListener.onGroupInfoChanged(
                    groupID,
                    groupChangeInfoList,
                  );
                });
                break;
              case 'onReceiveJoinApplication':
                _catchListenerError(() {
                  groupListener.onReceiveJoinApplication(
                    groupID,
                    member,
                    opReason,
                  );
                });
                break;
              case 'onApplicationProcessed':
                _catchListenerError(() {
                  groupListener.onApplicationProcessed(
                    groupID,
                    opUser,
                    isAgreeJoin,
                    opReason,
                  );
                });
                break;
              case 'onGrantAdministrator':
                _catchListenerError(() {
                  groupListener.onGrantAdministrator(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                break;
              case 'onRevokeAdministrator':
                _catchListenerError(() {
                  groupListener.onRevokeAdministrator(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                break;
              case 'onQuitFromGroup':
                _catchListenerError(() {
                  groupListener.onQuitFromGroup(groupID);
                });
                break;
              case 'onReceiveRESTCustomData':
                _catchListenerError(() {
                  groupListener.onReceiveRESTCustomData(
                    groupID,
                    customData,
                  );
                });
                break;
              case 'onGroupAttributeChanged':
                _catchListenerError(() {
                  groupListener.onGroupAttributeChanged(
                    groupID,
                    groupAttributeMap,
                  );
                });
                break;
            }
          }
        } else if (call.method == ListenerType.advancedMsgListener) {
          Map<String, dynamic> data = this.formatJson(call.arguments);
          String listenerUuid = data['listenerUuid'];
          V2TimAdvancedMsgListener? listener =
              this.v2TIMMessageManager.advancedMsgListenerList[listenerUuid];
          String type = data['type'];
          dynamic params =
              data['data'] == null ? new Map<String, dynamic>() : data['data'];
          if (listener != null) {
            switch (type) {
              case 'onRecvNewMessage':
                listener.onRecvNewMessage(V2TimMessage.fromJson(params));
                break;
              case 'onRecvC2CReadReceipt':
                List dataList = params;
                List<V2TimMessageReceipt> receiptList =
                    List.empty(growable: true);
                dataList.forEach((element) {
                  receiptList.add(V2TimMessageReceipt.fromJson(element));
                });
                _catchListenerError(() {
                  listener.onRecvC2CReadReceipt(receiptList);
                });
                break;
              case 'onRecvMessageRevoked':
                _catchListenerError(() {
                  listener.onRecvMessageRevoked(params);
                });
                break;
              case 'onSendMessageProgress':
                final message = V2TimMessage.fromJson(params['message']);
                _catchListenerError(() {
                  listener.onSendMessageProgress(
                    message,
                    params['progress'],
                  );
                });

                break;
            }
          }
        } else if (call.method == ListenerType.conversationListener) {
          Map<String, dynamic> data = this.formatJson(call.arguments);
          String listenerUuid = data['listenerUuid'];
          String type = data['type'];

          V2TimConversationListener? listener =
              this.v2ConversationManager.conversationListenerList[listenerUuid];
          if (listener != null) {
            switch (type) {
              case 'onSyncServerStart':
                _catchListenerError(() {
                  listener.onSyncServerStart();
                });
                break;
              case 'onSyncServerFinish':
                _catchListenerError(() {
                  listener.onSyncServerFinish();
                });
                break;
              case 'onSyncServerFailed':
                _catchListenerError(() {
                  listener.onSyncServerFailed();
                });
                break;
              case 'onNewConversation':
                dynamic params = data['data'] == null
                    ? List.empty(growable: true)
                    : List.from(data['data']);
                List<V2TimConversation> conversationList =
                    List.empty(growable: true);
                params.forEach((element) {
                  conversationList.add(V2TimConversation.fromJson(element));
                });
                _catchListenerError(() {
                  listener.onNewConversation(conversationList);
                });
                break;
              case 'onConversationChanged':
                dynamic params = data['data'] == null
                    ? List.empty(growable: true)
                    : List.from(data['data']);
                List<V2TimConversation> conversationList =
                    List.empty(growable: true);
                params.forEach((element) {
                  conversationList.add(V2TimConversation.fromJson(element));
                });

                _catchListenerError(() {
                  listener.onConversationChanged(conversationList);
                });
                break;
              case 'onTotalUnreadMessageCountChanged':
                dynamic params = data['data'] == null ? 0 : data['data'];
                _catchListenerError(() {
                  listener.onTotalUnreadMessageCountChanged(params);
                });
                break;
            }
          }
        } else if (call.method == ListenerType.friendListener) {
          Map<String, dynamic> data = this.formatJson(call.arguments);
          String listenerUuid = data['listenerUuid'];
          String type = data['type'];
          dynamic params =
              data['data'] == null ? new Map<String, dynamic>() : data['data'];
          V2TimFriendshipListener? listener =
              this.v2TIMFriendshipManager.friendListenerList[listenerUuid];
          if (listener != null) {
            switch (type) {
              case 'onFriendApplicationListAdded':
                List applicationListMap = params;
                List<V2TimFriendApplication> applicationList =
                    List.empty(growable: true);
                applicationListMap.forEach((element) {
                  applicationList.add(V2TimFriendApplication.fromJson(element));
                });
                _catchListenerError(() {
                  listener.onFriendApplicationListAdded(applicationList);
                });
                break;
              case 'onFriendApplicationListDeleted':
                List<String> userIDList = List.from(params);
                _catchListenerError(() {
                  listener.onFriendApplicationListDeleted(userIDList);
                });
                break;
              case 'onFriendApplicationListRead':
                _catchListenerError(() {
                  listener.onFriendApplicationListRead();
                });
                break;
              case 'onFriendListAdded':
                List userMap = params;
                List<V2TimFriendInfo> users = List.empty(growable: true);
                userMap.forEach((element) {
                  users.add(V2TimFriendInfo.fromJson(element));
                });
                _catchListenerError(() {
                  listener.onFriendListAdded(users);
                });
                break;
              case 'onFriendListDeleted':
                List<String> userList = List.from(params);
                _catchListenerError(() {
                  listener.onFriendListDeleted(userList);
                });
                break;
              case 'onBlackListAdd':
                List infoListMap = params;
                List<V2TimFriendInfo> infoList = List.empty(growable: true);
                infoListMap.forEach((element) {
                  infoList.add(V2TimFriendInfo.fromJson(element));
                });
                _catchListenerError(() {
                  listener.onBlackListAdd(infoList);
                });
                break;
              case 'onBlackListDeleted':
                List<String> userList = List.from(params);
                _catchListenerError(() {
                  listener.onBlackListDeleted(userList);
                });
                break;
              case 'onFriendInfoChanged':
                List infoListMap = params;
                List<V2TimFriendInfo> infoList = List.empty(growable: true);
                infoListMap.forEach((element) {
                  infoList.add(V2TimFriendInfo.fromJson(element));
                });
                _catchListenerError(() {
                  listener.onFriendInfoChanged(infoList);
                });
                break;
            }
          }
        } else if (call.method == 'logFromSwift') {
          var data = call.arguments["data"];
          var msg = call.arguments["msg"];
          print('========> $msg: $data');
        } else if (call.method == ListenerType.signalingListener) {
          Map<String, dynamic> d = this.formatJson(call.arguments);
          String listenerUuid = d['listenerUuid'];
          String type = d['type'];
          Map<String, dynamic> params = d['data'];
          String inviteID =
              params['inviteID'] == null ? '' : params['inviteID'];
          String inviter = params['inviter'] == null ? '' : params['inviter'];
          String groupID = params['groupID'] == null ? '' : params['groupID'];
          List<String>? inviteeList = params['inviteeList'] == null
              ? null
              : List.from(params['inviteeList']);
          String data = params['data'] == null ? '' : params['data'];
          String invitee = params['invitee'] == null ? '' : params['invitee'];
          V2TimSignalingListener? listener =
              this.v2timSignalingManager.signalingListenerList[listenerUuid];
          switch (type) {
            case 'onReceiveNewInvitation':
              _catchListenerError(() {
                listener!.onReceiveNewInvitation(
                    inviteID, inviter, groupID, inviteeList!, data);
              });
              break;
            case 'onInviteeAccepted':
              _catchListenerError(() {
                listener!.onInviteeAccepted(inviteID, invitee, data);
              });
              break;
            case 'onInviteeRejected':
              _catchListenerError(() {
                listener!.onInviteeRejected(inviteID, invitee, data);
              });
              break;
            case 'onInvitationCancelled':
              _catchListenerError(() {
                listener!.onInvitationCancelled(inviteID, inviter, data);
              });
              break;
            case 'onInvitationTimeout':
              _catchListenerError(() {
                listener!.onInvitationTimeout(inviteID, inviteeList!);
              });
              break;
          }
        }
      } catch (err) {
        print(
            "重点关注，回调失败了，数据类型异常。$err ${call.method} ${call.arguments['type']} ${call.arguments['data']}");
      }
      return Future.value(null);
    });
  }

  /// 初始化SDK
  ///
  /// 参数
  ///
  /// ```
  /// @required int sdkAppID	应用 ID，必填项，可以在控制台中获取
  /// @required LogLevelEnum loglevel	配置信息
  /// @required [InitListener] listener	SDK的回调
  /// ```
  ///
  /// 返回
  /// ```
  /// true：成功；
  /// false：失败
  /// ```
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required LogLevelEnum loglevel,
    required V2TimSDKListener listener,
  }) {
    final String uuid = Uuid().v4();
    this.initSDKListenerList[uuid] = listener;
    return ImFlutterPlatform.instance.initSDK(
      sdkAppID: sdkAppID,
      loglevel: EnumUtils.convertLogLevelEnum(loglevel),
      listenerUuid: uuid,
      listener: listener,
    );
  }

  ///反初始化 SDK
  ///
  Future<V2TimCallback> unInitSDK() {
    this.initSDKListenerList = {};
    return ImFlutterPlatform.instance.unInitSDK();
  }

  /// 获取版本号
  ///
  Future<V2TimValueCallback<String>> getVersion() {
    return ImFlutterPlatform.instance.getVersion();
  }

  /// 获取服务器当前时间
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<int>> getServerTime() {
    return ImFlutterPlatform.instance.getServerTime();
  }

  /// 登录
  ///
  /// 参数
  ///
  /// ```
  /// @required String userID,
  /// @required String userSig,
  /// ```
  ///
  /// ```
  /// 登录需要设置用户名 userID 和用户签名 userSig，userSig 生成请参考 UserSig 后台 API。
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 登陆时票据过期：login 函数的回调会返回 ERR_USER_SIG_EXPIRED：6206 错误码，此时生成新的 userSig 重新登录。
  /// 在线时票据过期：用户在线期间也可能收到 V2TIMListener -> onUserSigExpired 回调，此时也是需要您生成新的 userSig 并重新登录。
  /// 在线时被踢下线：用户在线情况下被踢，SDK 会通过 V2TIMListener -> onKickedOffline 回调通知给您，此时可以 UI 提示用户，并再次调用 login() 重新登录。
  /// ```
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) {
    return ImFlutterPlatform.instance.login(userID: userID, userSig: userSig);
  }

  /// 登出
  ///
  ///```
  /// 退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
  ///```
  Future<V2TimCallback> logout() async {
    return ImFlutterPlatform.instance.logout();
  }

  /// 获取登录用户
  ///
  Future<V2TimValueCallback<String>> getLoginUser() async {
    return ImFlutterPlatform.instance.getLoginUser();
  }

  /// 获取登录状态
  ///
  ///```
  /// 如果用户已经处于已登录和登录中状态，请勿再频繁调用登录接口登录。
  /// ```
  ///
  /// 返回
  ///
  ///```
  /// 登录状态
  /// V2TIM_STATUS_LOGINED 已登录
  /// V2TIM_STATUS_LOGINING 登录中
  /// V2TIM_STATUS_LOGOUT 无登录
  /// ```
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    return ImFlutterPlatform.instance.getLoginStatus();
  }

  /// 发送单聊普通文本消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// ```
  /// 文本消息支持云端的脏词过滤，如果用户发送的消息中有敏感词，callback 回调将会返回 80001 错误码。
  /// ```
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认会推送（前提是在 V2TIMOfflinePushManager 开启了推送），如果需要自定义推送（标题和内容），请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    printWarning(
        "tencent_im_sdk_plugin：简单消息接口自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return ImFlutterPlatform.instance.sendC2CTextMessage(
      text: text,
      userID: userID,
    );
  }

  /// 发送单聊自定义（信令）消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// ```
  /// 自定义消息本质就是一端二进制 buffer，您可以在其上自由组织自己的消息格式（常用于发送信令），但是自定义消息不支持云端敏感词过滤。
  /// ```
  ///
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  /// ```
  /// 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    printWarning("简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return ImFlutterPlatform.instance.sendC2CCustomMessage(
      customData: customData,
      userID: userID,
    );
  }

  /// 发送群聊普通文本消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// 参数
  ///
  /// ```
  /// priority	设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
  /// V2TIMMessage.V2TIM_PRIORITY_HIGH = 1：云端会优先传输，适用于在群里发送重要消息，比如主播发送的文本消息等。
  /// V2TIMMessage.V2TIM_PRIORITY_NORMAL = 2：云端按默认优先级传输，适用于在群里发送非重要消息，比如观众发送的弹幕消息等。
  /// ```
  ///
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认会推送（前提是在 V2TIMOfflinePushManager 开启了推送），如果需要自定义推送（标题和内容），请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    printWarning("简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return ImFlutterPlatform.instance
        .sendGroupTextMessage(text: text, groupID: groupID, priority: priority);
  }

  /// 发送群聊自定义（信令）消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// 参数
  ///
  /// ```
  /// priority	设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
  /// V2TIMMessage.V2TIM_PRIORITY_HIGH = 1：云端会优先传输，适用于在群里发送重要信令，比如连麦邀请，PK邀请、礼物赠送等关键性信令。
  /// V2TIMMessage.V2TIM_PRIORITY_NORMAL = 2：云端按默认优先级传输，适用于在群里发送非重要信令，比如观众的点赞提醒等等。
  /// ```
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
  }) async {
    printWarning("简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return ImFlutterPlatform.instance.sendGroupCustomMessage(
        customData: customData,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority));
  }

  /// 创建群组
  ///
  ///参数
  ///```
  /// groupType	群类型，我们为您预定义好了四种常用的群类型，您也可以在控制台定义自己需要的群类型：
  ///
  ///   "Work" ：工作群，成员上限 200 人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
  ///
  ///   "Public" ：公开群，成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
  ///
  ///   "Meeting" ：会议群，成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
  ///
  ///   "AVChatRoom" ：直播群，人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
  ///
  /// groupID	自定义群组 ID，可以传 null。传 null 时系统会自动分配 groupID，并通过 callback 返回。
  ///
  /// groupName	群名称，不能为 null。
  ///```
  /// 注意
  ///
  ///```
  /// 不支持在同一个 SDKAPPID 下创建两个相同 groupID 的群
  /// ```
  Future<V2TimValueCallback<String>> createGroup({
    required String groupType,
    required String groupName,
    String? groupID,
  }) async {
    return ImFlutterPlatform.instance.createGroup(
        groupType: groupType, groupName: groupName, groupID: groupID);
  }

  /// 加入群组
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：不能主动入群，只能通过群成员调用 V2TIMManager.getGroupManager().inviteUserToGroup() 接口邀请入群。
  /// 公开群（Public）：申请入群后，需要管理员审批，管理员在收到 V2TIMGroupListener -> onReceiveJoinApplication 回调后调用 V2TIMManager.getGroupManager().getGroupApplicationList() 接口处理加群请求。
  /// 其他群：可以直接入群。
  /// 注意：当在web端时，加入直播群时groupType字段必填
  /// ```
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    return ImFlutterPlatform.instance
        .joinGroup(groupID: groupID, message: message, groupType: groupType);
  }

  /// 退出群组
  ///
  /// 注意
  ///
  /// ```
  /// 在公开群（Public）、会议（Meeting）和直播群（AVChatRoom）中，群主是不可以退群的，群主只能调用 dismissGroup 解散群组。
  /// ```
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    return ImFlutterPlatform.instance.quitGroup(groupID: groupID);
  }

  /// 解散群组
  ///
  /// 注意
  ///
  /// ```
  /// Work：任何人都无法解散群组。
  /// 其他群：群主可以解散群组。
  /// ```
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    return ImFlutterPlatform.instance.dismissGroup(groupID: groupID);
  }

  /// 获取用户资料
  ///
  /// 注意
  ///
  /// ```
  /// 获取自己的资料，传入自己的 ID 即可。
  /// userIDList 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// ```
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    return ImFlutterPlatform.instance.getUsersInfo(
      userIDList: userIDList,
    );
  }

  /// 修改个人资料
  ///
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    return ImFlutterPlatform.instance.setSelfInfo(userFullInfo: userFullInfo);
  }

  /// 实验性 API 接口
  ///
  /// 参数
  /// api	接口名称
  /// param	接口参数
  // 注意
  /// 该接口提供一些实验性功能
  ///
  /// 注意：web不支持该接口
  ///
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    return ImFlutterPlatform.instance
        .callExperimentalAPI(api: api, param: param);
  }

  /// 高级消息功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 高级消息管理类实例
  /// ```
  V2TIMMessageManager getMessageManager() {
    return this.v2TIMMessageManager;
  }

  /// 高级群组功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 高级群组管理类实例
  /// ```
  V2TIMGroupManager getGroupManager() {
    return this.v2TIMGroupManager;
  }

  /// 会话功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 会话管理类实例
  /// ```
  V2TIMConversationManager getConversationManager() {
    return this.v2ConversationManager;
  }

  /// 关系链功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 关系链管理类实例
  /// ```
  V2TIMFriendshipManager getFriendshipManager() {
    return this.v2TIMFriendshipManager;
  }

  /// 离线推送功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 离线推送功能类实例
  /// ```
  V2TIMOfflinePushManager getOfflinePushManager() {
    return this.v2TIMOfflinePushManager;
  }

  /// 信令入口
  ///
  /// 返回
  ///
  /// ```
  /// 信令管理类实例
  /// ```
  V2TIMSignalingManager getSignalingManager() {
    return this.v2timSignalingManager;
  }

  /// 设置基本消息（文本消息和自定义消息）的事件监听器
  ///
  /// 注意
  ///
  /// ```
  /// 图片消息、视频消息、语音消息等高级消息的监听，请参考: V2TIMMessageManager.addAdvancedMsgListener(V2TIMAdvancedMsgListener) 。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<void> addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  }) {
    final uuid = Uuid().v4();
    this.simpleMessageListenerList[uuid] = listener;
    return ImFlutterPlatform.instance
        .addSimpleMsgListener(listener: listener, listenerUuid: uuid);
  }

  /// 移除基本消息（文本消息和自定义消息）的事件监听器
  ///
  /// 如果传入listener，会移除指定listener的事件监听器。如果未传入listener会移除所有addSimpleMsgListener的事件监听器。
  ///
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<void> removeSimpleMsgListener({V2TimSimpleMsgListener? listener}) {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = this.simpleMessageListenerList.keys.firstWhere(
          (k) => this.simpleMessageListenerList[k] == listener,
          orElse: () => "");
      this.simpleMessageListenerList.remove(listenerUuid);
    } else {
      this.simpleMessageListenerList.clear();
    }
    return ImFlutterPlatform.instance
        .removeSimpleMsgListener(listenerUuid: listenerUuid);
  }

  /// 设置群组监听器
  ///
  /// 在web端时，不支持onQuitFromGroup回调
  ///
  Future<void> setGroupListener({
    required V2TimGroupListener listener,
  }) {
    final uuid = Uuid().v4();
    this.groupListenerList[uuid] = listener;
    return ImFlutterPlatform.instance
        .setGroupListener(listener: listener, listenerUuid: uuid);
  }

  /// 设置apns监听
  ///
  Future setAPNSListener() {
    return ImFlutterPlatform.instance.setAPNSListener();
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "timManager";
    return param;
  }

  void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }
}
