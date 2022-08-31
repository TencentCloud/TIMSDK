// ignore_for_file: empty_catches

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/V2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversationList_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_signaling_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_status.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/utils/utils.dart';

import 'enum/V2TimSDKListener.dart';
import 'models/v2_tim_group_member_full_info.dart';
import 'models/v2_tim_msg_create_info_result.dart';

const MethodChannel _channel = MethodChannel('tencent_im_sdk_plugin');

class MethodChannelIm extends ImFlutterPlatform {
  /*
    Web SDK其实用不到这个chennael层
  */
  /* *****-基础模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */
  @override
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required int loglevel,
    String? listenerUuid,
    V2TimSDKListener? listener,
    required String uiPlatform,
  }) async {
    return V2TimValueCallback<bool>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'initSDK',
          buildTimManagerParam(
            {
              "sdkAppID": sdkAppID,
              "logLevel": loglevel,
              "listenerUuid": listenerUuid,
              "uiPlatform": uiPlatform
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> unInitSDK() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'unInitSDK',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<String>> getVersion() async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getVersion',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<int>> getServerTime() async {
    return V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getServerTime',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'login',
          buildTimManagerParam({
            "userID": userID,
            "userSig": userSig,
          }),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> logout() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'logout',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendC2CTextMessage',
          buildTimManagerParam(
            {
              "text": text,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendC2CCustomMessage',
          buildTimManagerParam(
            {
              "customData": customData,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendGroupTextMessage",
          buildTimManagerParam(
            {
              "text": text,
              "groupID": groupID,
              "priority": priority,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    int priority = 0,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendGroupCustomMessage",
          buildTimManagerParam(
            {
              "customData": customData,
              "groupID": groupID,
              "priority": priority,
            },
          ),
        ),
      ),
    );
  }

  /// 获取登录用户
  ///
  @override
  Future<V2TimValueCallback<String>> getLoginUser() async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getLoginUser',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    return V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getLoginStatus',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimUserFullInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getUsersInfo",
          buildTimManagerParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    int? addOpt,
    List<V2TimGroupMember>? memberList,
    bool? isSupportTopic,
  }) async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createGroup",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "groupType": groupType,
              "groupName": groupName,
              "notification": notification,
              "introduction": introduction,
              "faceUrl": faceUrl,
              "isAllMuted": isAllMuted,
              "addOpt": addOpt,
              "memberList": memberList?.map((e) => e.toJson()).toList(),
              "isSupportTopic": isSupportTopic
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "joinGroup",
          buildTimManagerParam(
            {
              "groupID": groupID,
              "message": message,
              "groupType": groupType,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "quitGroup",
          buildTimManagerParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "dismissGroup",
          buildTimManagerParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setSelfInfo",
          buildTimManagerParam(
            {
              "nickName": userFullInfo.nickName,
              "faceUrl": userFullInfo.faceUrl,
              "selfSignature": userFullInfo.selfSignature,
              "birthday": userFullInfo.birthday,
              "gender": userFullInfo.gender,
              "allowType": userFullInfo.allowType,
              "customInfo": userFullInfo.customInfo,
              "level": userFullInfo.level,
              "role": userFullInfo.role,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    return V2TimValueCallback<Object>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "callExperimentalAPI",
          buildTimManagerParam(
            {
              "api": api,
              "param": param,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<void> addSimpleMsgListener(
      {required V2TimSimpleMsgListener listener, String? listenerUuid}) async {
    return _channel.invokeMethod("addSimpleMsgListener",
        buildTimManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> removeSimpleMsgListener({
    String? listenerUuid,
  }) async {
    return _channel.invokeMethod("removeSimpleMsgListener",
        buildTimManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future setAPNSListener() {
    return _channel.invokeMethod("setAPNSListener", buildTimManagerParam({}));
  }

  /* *****-会话模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */
  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    return V2TimValueCallback<V2TimConversationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getConversationList",
          buildConversationManagerParam(
            {
              "nextSeq": nextSeq,
              "count": count,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<void> removeConversationListener({String? listenerUuid}) async {
    return _channel.invokeMethod("removeConversationListener",
        buildConversationManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> removeFriendListener({String? listenerUuid}) async {
    return _channel.invokeMethod("removeFriendListener",
        buildFriendManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> removeGroupListener({
    String? listenerUuid,
  }) async {
    return _channel.invokeMethod("removeGroupListener",
        buildTimManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> addConversationListener({
    required V2TimConversationListener listener,
    String? listenerUuid,
  }) async {
    return await _channel.invokeMethod(
        "addConversationListener",
        buildConversationManagerParam(
          {
            "listenerUuid": listenerUuid,
          },
        ));
  }

  @override
  Future<void> addGroupListener({
    required V2TimGroupListener listener,
    String? listenerUuid,
  }) async {
    return await _channel.invokeMethod(
        "addGroupListener",
        buildTimManagerParam(
          {
            "listenerUuid": listenerUuid,
          },
        ));
  }

  @override
  Future<void> addFriendListener({
    required V2TimFriendshipListener listener,
    String? listenerUuid,
  }) async {
    return await _channel.invokeMethod(
        "addFriendListener",
        buildFriendManagerParam(
          {
            "listenerUuid": listenerUuid,
          },
        ));
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    return V2TimValueCallback<List<V2TimConversation>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getConversationListByConversaionIds",
          buildConversationManagerParam(
            {
              "conversationIDList": conversationIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<void> setConversationListener(
      {required V2TimConversationListener listener,
      String? listenerUuid}) async {
    return _channel.invokeMethod("setConversationListener",
        buildConversationManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    /*required*/ required String conversationID,
  }) async {
    return V2TimValueCallback<V2TimConversation>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getConversation',
          buildConversationManagerParam(
            {
              "conversationID": conversationID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> deleteConversation({
    /*required*/ required String conversationID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteConversation",
          buildConversationManagerParam(
            {
              "conversationID": conversationID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setConversationDraft",
          buildConversationManagerParam(
            {
              "conversationID": conversationID,
              "draftText": draftText,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "pinConversation",
          buildConversationManagerParam(
            {
              "conversationID": conversationID,
              "isPinned": isPinned,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    return V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getTotalUnreadMessageCount",
          buildConversationManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  /* *****-好友关系模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */
  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendList",
          buildFriendManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<void> setFriendListener(
      {required V2TimFriendshipListener listener, String? listenerUuid}) async {
    return _channel.invokeMethod("setFriendListener",
        buildFriendManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendsInfo",
          buildFriendManagerParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addFriend",
          buildFriendManagerParam(
            {
              "userID": userID,
              "remark": remark,
              "friendGroup": friendGroup,
              "addWording": addWording,
              "addSource": addSource,
              "addType": addType,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setFriendInfo",
          buildFriendManagerParam(
            {
              "userID": userID,
              "friendRemark": friendRemark,
              "friendCustomInfo": friendCustomInfo,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFromFriendList",
          buildFriendManagerParam(
            {
              "userIDList": userIDList,
              "deleteType": deleteType,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    return V2TimValueCallback<List<V2TimFriendCheckResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "checkFriend",
          buildFriendManagerParam(
            {
              "userIDList": userIDList,
              "checkType": checkType,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    return V2TimValueCallback<V2TimFriendApplicationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendApplicationList",
          buildFriendManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "acceptFriendApplication",
          buildFriendManagerParam(
            {
              "responseType": responseType,
              "type": type,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "refuseFriendApplication",
          buildFriendManagerParam(
            {
              "type": type,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendApplication",
          buildFriendManagerParam(
            {
              "type": type,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setFriendApplicationRead() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setFriendApplicationRead",
          buildFriendManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getBlackList",
          buildFriendManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addToBlackList",
          buildFriendManagerParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFromBlackList",
          buildFriendManagerParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createFriendGroup",
          buildFriendManagerParam(
            {
              "groupName": groupName,
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendGroup>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendGroups",
          buildFriendManagerParam(
            {
              "groupNameList": groupNameList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendGroup",
          buildFriendManagerParam(
            {
              "groupNameList": groupNameList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "renameFriendGroup",
          buildFriendManagerParam(
            {
              "oldName": oldName,
              "newName": newName,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addFriendsToFriendGroup",
          buildFriendManagerParam(
            {
              "groupName": groupName,
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendsFromFriendGroup",
          buildFriendManagerParam(
            {
              "groupName": groupName,
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchFriends",
          buildFriendManagerParam(
            {
              "searchParam": searchParam.toJson(),
            },
          ),
        ),
      ),
    );
  }
  /* *****-群组模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getJoinedGroupList",
          buildGroupManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<void> setGroupListener(
      {required V2TimGroupListener listener, String? listenerUuid}) async {
    return _channel.invokeMethod("setGroupListener",
        buildTimManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    return V2TimValueCallback<List<V2TimGroupInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupsInfo",
          buildGroupManagerParam(
            {
              "groupIDList": groupIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupInfo",
          buildGroupManagerParam(
            {
              "groupID": info.groupID,
              "groupType": info.groupType,
              "groupName": info.groupName,
              "notification": info.notification,
              "introduction": info.introduction,
              "faceUrl": info.faceUrl,
              "isAllMuted": info.isAllMuted,
              "addOpt": info.groupAddOpt,
              "customInfo": info.customInfo,
              "isSupportTopic": info.isSupportTopic
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupAttributes",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "attributes": attributes,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteGroupAttributes",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "keys": keys,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    return V2TimValueCallback<Map<String, String>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupAttributes",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "keys": keys,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    return V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupOnlineMemberCount",
          buildGroupManagerParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    return V2TimValueCallback<V2TimGroupMemberInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMemberList",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "filter": filter,
              "nextSeq": nextSeq,
              "count": count,
              "offset": offset
            },
          ),
        ),
      ),
    );
  }

  @override

  ///获取指定的群成员资料
  ///
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    return V2TimValueCallback<List<V2TimGroupMemberFullInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMembersInfo",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "memberList": memberList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupMemberInfo",
          buildGroupManagerParam(
            {
              "userID": userID,
              "groupID": groupID,
              "nameCard": nameCard,
              "customInfo": customInfo
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "muteGroupMember",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "userID": userID,
              "seconds": seconds,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    return V2TimValueCallback<List<V2TimGroupMemberOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "inviteUserToGroup",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "userList": userList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "kickGroupMember",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "memberList": memberList,
              "reason": reason,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupMemberRole",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "userID": userID,
              "role": role,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "transferGroupOwner",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    return V2TimValueCallback<V2TimGroupApplicationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupApplicationList",
          buildGroupManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "acceptGroupApplication",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "reason": reason,
              "fromUser": fromUser,
              "toUser": toUser,
              "addTime": addTime,
              "type": type,
              "webMessageInstance": webMessageInstance
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required int type,
    String? webMessageInstance,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "refuseGroupApplication",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "reason": reason,
              "fromUser": fromUser,
              "toUser": toUser,
              "addTime": addTime,
              "type": type,
              "webMessageInstance": webMessageInstance
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setGroupApplicationRead() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupApplicationRead",
          buildGroupManagerParam(
            {},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchGroups",
          buildGroupManagerParam(
            {
              "searchParam": searchParam.toJson(),
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    return V2TimValueCallback<V2GroupMemberInfoSearchResult>.fromJson(
      formatJson(await _channel.invokeMethod(
        "searchGroupMembers",
        buildGroupManagerParam(
          {
            "param": param.toJson(),
          },
        ),
      )),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimGroupInfo>> searchGroupByID({
    required String groupID,
  }) async {
    return V2TimValueCallback<V2TimGroupInfo>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchGroupByID",
          buildGroupManagerParam(
            {"groupID": groupID},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "initGroupAttributes",
          buildGroupManagerParam(
            {
              "groupID": groupID,
              "attributes": attributes,
            },
          ),
        ),
      ),
    );
  }

  /* *****-消息模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */

  /// 创建文本消息
  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage(
      {required String text}) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createTextMessage",
          buildMessageMangerParam(
            {
              "text": text,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createTargetedGroupMessage(
          {required String id, required List<String> receiverList}) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createTargetedGroupMessage",
          buildMessageMangerParam(
            {"id": id, "receiverList": receiverList},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage({
    required String data,
    String desc = "",
    String extension = "",
  }) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createCustomMessage",
          buildMessageMangerParam(
            {
              "data": data,
              "desc": desc,
              "extension": extension,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage(
      {required String imagePath, dynamic inputElement}) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createImageMessage",
          buildMessageMangerParam(
            {"imagePath": imagePath},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createSoundMessage",
          buildMessageMangerParam(
            {
              "soundPath": soundPath,
              "duration": duration,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage({
    required String videoFilePath,
    required String type,
    required int duration,
    required String snapshotPath,
    dynamic inputElement,
  }) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createVideoMessage",
          buildMessageMangerParam(
            {
              "videoFilePath": videoFilePath,
              "type": type,
              "duration": duration,
              "snapshotPath": snapshotPath,
            },
          ),
        ),
      ),
    );
  }

  ///发送消息
  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      bool isExcludedFromLastMessage = false,
      bool needReadReceipt = false,
      Map<String, dynamic>? offlinePushInfo,
      // 自定义消息需要
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData}) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendMessage",
          buildMessageMangerParam(
            {
              "id": id,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "isExcludedFromLastMessage": isExcludedFromLastMessage,
              "offlinePushInfo": offlinePushInfo,
              "cloudCustomData": cloudCustomData,
              "localCustomData": localCustomData,
              "needReadReceipt": needReadReceipt,
            },
          ),
        ),
      ),
    );
  }

  /// 发送文件消息
  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage(
      {required String filePath,
      required String fileName,
      dynamic inputElement}) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createFileMessage",
          buildMessageMangerParam(
            {
              "filePath": filePath,
              "fileName": fileName,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createTextAtMessage',
          buildMessageMangerParam(
            {
              "text": text,
              "atUserList": atUserList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createLocationMessage',
          buildMessageMangerParam(
            {"desc": desc, "longitude": longitude, "latitude": latitude},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createFaceMessage',
          buildMessageMangerParam(
            {"index": index, "data": data},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      List<String>? webMessageInstanceList}) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createMergerMessage',
          buildMessageMangerParam(
            {
              "msgIDList": msgIDList,
              "title": title,
              "abstractList": abstractList,
              "compatibleText": compatibleText,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID, String? webMessageInstance}) async {
    return V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createForwardMessage',
          buildMessageMangerParam(
            {"msgID": msgID, "webMessageInstance": webMessageInstance},
          ),
        ),
      ),
    );
  }
  /*
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "desc": desc,
              "extension": extension,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
  */

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendTextMessage",
          buildMessageMangerParam(
            {
              "text": text,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    String desc = "",
    String extension = "",
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendCustomMessage",
          buildMessageMangerParam(
            {
              "data": data,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "desc": desc,
              "extension": extension,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendImageMessage(
      {required String imagePath,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? fileName,
      Uint8List? fileContent}) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendImageMessage",
          buildMessageMangerParam(
            {
              "imagePath": imagePath,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
              "fileName": fileName,
              "fileContent": fileContent
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendVideoMessage({
    required String videoFilePath,
    required String receiver,
    required String type,
    required String snapshotPath,
    required int duration,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
    String? fileName,
    Uint8List? fileContent,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendVideoMessage",
          buildMessageMangerParam(
            {
              "videoFilePath": videoFilePath,
              "receiver": receiver,
              "snapshotPath": snapshotPath,
              "duration": duration,
              "type": type,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
              "fileName": fileName,
              "fileContent": fileContent
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFileMessage(
      {required String filePath,
      required String fileName,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      Uint8List? fileContent}) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendFileMessage",
          buildMessageMangerParam(
            {
              "filePath": filePath,
              "fileName": fileName,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
              "fileContent": fileContent
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage({
    required String soundPath,
    required String receiver,
    required String groupID,
    required int duration,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendSoundMessage",
          buildMessageMangerParam(
            {
              "soundPath": soundPath,
              "receiver": receiver,
              "duration": duration,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage({
    required String text,
    required List<String> atUserList,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendTextAtMessage',
          buildMessageMangerParam(
            {
              "text": text,
              "atUserList": atUserList,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
            },
          ),
        ),
      ),
    );
  }

  /// 发送地理位置消息
  ///
  @override
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendLocationMessage',
          buildMessageMangerParam(
            {
              "desc": desc,
              "longitude": longitude,
              "latitude": latitude,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage({
    required int index,
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendFaceMessage',
          buildMessageMangerParam(
            {
              "index": index,
              "data": data,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      List<String>? webMessageInstanceList}) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendMergerMessage',
          buildMessageMangerParam(
            {
              "msgIDList": msgIDList,
              "title": title,
              "abstractList": abstractList,
              "compatibleText": compatibleText,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
              "webMessageInstanceList": webMessageInstanceList
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setLocalCustomData",
          buildMessageMangerParam(
            {
              "localCustomData": localCustomData,
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setLocalCustomInt",
          buildMessageMangerParam(
            {
              "msgID": msgID,
              "localCustomInt": localCustomInt,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setCloudCustomData",
          buildMessageMangerParam(
            {
              "msgID": msgID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getC2CHistoryMessageList",
          buildMessageMangerParam(
            {
              "userID": userID,
              "count": count,
              "lastMsgID": lastMsgID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getHistoryMessageList",
          buildMessageMangerParam(
            {
              "getType": getType,
              "userID": userID,
              "groupID": groupID,
              'lastMsgSeq': lastMsgSeq,
              "count": count,
              "lastMsgID": lastMsgID,
              "messageTypeList": messageTypeList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    return await _channel.invokeMethod(
      "getHistoryMessageList",
      buildMessageMangerParam(
        {
          "getType": getType,
          "userID": userID,
          "groupID": groupID,
          'lastMsgSeq': lastMsgSeq,
          "count": count,
          "lastMsgID": lastMsgID,
        },
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupHistoryMessageList",
          buildMessageMangerParam(
            {
              "groupID": groupID,
              "count": count,
              "lastMsgID": lastMsgID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> revokeMessage(
      {required String msgID, Object? webMessageInstatnce}) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "revokeMessage",
          buildMessageMangerParam(
            {"msgID": msgID, "webMessageInstatnce": webMessageInstatnce},
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markC2CMessageAsRead",
          buildMessageMangerParam(
            {
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage(
      {required String msgID,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? webMessageInstance}) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendForwardMessage',
          buildMessageMangerParam(
            {
              "msgID": msgID,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
              "webMessageInstance": webMessageInstance
            },
          ),
        ),
      ),
    );
  }

  /*
   注意：reSendMessage的onProgress不会返回id
  */
  @override
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage(
      {required String msgID,
      bool onlineUserOnly = false,
      Object? webMessageInstatnce}) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "reSendMessage",
          buildMessageMangerParam(
            {
              "msgID": msgID,
              "onlineUserOnly": onlineUserOnly,
              "webMessageInstatnce": webMessageInstatnce
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setC2CReceiveMessageOpt",
          buildMessageMangerParam(
            {
              "userIDList": userIDList,
              "opt": opt,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getC2CReceiveMessageOpt",
          buildMessageMangerParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required int opt,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupReceiveMessageOpt",
          buildMessageMangerParam(
            {
              "groupID": groupID,
              "opt": opt,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markGroupMessageAsRead",
          buildMessageMangerParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessageFromLocalStorage",
          buildMessageMangerParam(
            {
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> deleteMessages(
      {required List<String> msgIDs,
      List<dynamic>? webMessageInstanceList}) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessages",
          buildMessageMangerParam(
            {
              "msgIDs": msgIDs,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertGroupMessageToLocalStorage",
          buildMessageMangerParam(
            {
              "data": data,
              "groupID": groupID,
              "sender": sender,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertC2CMessageToLocalStorage",
          buildMessageMangerParam(
            {
              "data": data,
              "userID": userID,
              "sender": sender,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "clearC2CHistoryMessage",
          buildMessageMangerParam(
            {
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "clearGroupHistoryMessage",
          buildMessageMangerParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return V2TimValueCallback<V2TimMessageSearchResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchLocalMessages",
          buildMessageMangerParam(
            {
              "searchParam": searchParam.toJson(),
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "findMessages",
          buildMessageMangerParam(
            {
              "messageIDList": messageIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> markAllMessageAsRead() async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
        "markAllMessageAsRead", buildMessageMangerParam({}))));
  }

  @override

  /// 添加高级消息的事件监听器
  ///
  Future<void> addAdvancedMsgListener(
      {required V2TimAdvancedMsgListener listener,
      String? listenerUuid}) async {
    return await _channel.invokeMethod("addAdvancedMsgListener",
        buildMessageMangerParam({"listenerUuid": listenerUuid}));
  }

  @override

  /// 移除高级消息监听器
  ///
  Future<void> removeAdvancedMsgListener({String? listenerUuid}) async {
    return _channel.invokeMethod("removeAdvancedMsgListener",
        buildMessageMangerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      "sendMessageReadReceipts",
      buildMessageMangerParam(
        {
          "messageIDList": messageIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    return V2TimValueCallback<List<V2TimMessageReceipt>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMessageReadReceipts",
          buildMessageMangerParam(
            {
              "messageIDList": messageIDList,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) async {
    return V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMessageReadMemberList",
          buildMessageMangerParam(
            {
              "messageID": messageID,
              "filter": filter.index,
              "nextSeq": nextSeq,
              "count": count,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(formatJson(
        await _channel.invokeMethod(
            'getJoinedCommunityList', buildGroupManagerParam({}))));
  }

  @override
  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return V2TimValueCallback<String>.fromJson(formatJson(
        await _channel.invokeMethod(
            'createTopicInCommunity',
            buildGroupManagerParam(
                {"groupID": groupID, "topicInfo": topicInfo.toJson()}))));
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson(
        formatJson(await _channel.invokeMethod(
            'deleteTopicFromCommunity',
            buildGroupManagerParam(
                {"groupID": groupID, "topicIDList": topicIDList}))));
  }

  @override
  Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
        'setTopicInfo',
        buildGroupManagerParam({
          "topicInfo": topicInfo.toJson(),
          "groupID": groupID,
        }))));
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return V2TimValueCallback<List<V2TimTopicInfoResult>>.fromJson(formatJson(
        await _channel.invokeMethod(
            'getTopicInfoList',
            buildGroupManagerParam(
                {"groupID": groupID, "topicIDList": topicIDList}))));
  }

  @override
  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    return V2TimValueCallback<V2TimMessageChangeInfo>.fromJson(
        formatJson(await _channel.invokeMethod(
            'modifyMessage',
            buildMessageMangerParam({
              "message": message.toJson(),
            }))));
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
        formatJson(await _channel.invokeMethod(
            'appendMessage',
            buildMessageMangerParam({
              "createMessageBaseId": createMessageBaseId,
              "createMessageAppendId": createMessageAppendId,
            }))));
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimUserStatus>>.fromJson(
        formatJson(await _channel.invokeMethod(
            'getUserStatus',
            buildTimManagerParam({
              "userIDList": userIDList,
            }))));
  }

  @override
  Future<V2TimCallback> setSelfStatus({
    required String status,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
        'setSelfStatus',
        buildTimManagerParam({
          "status": status,
        }))));
  }

  @override
  Future<V2TimValueCallback<int>> checkAbility() async {
    return V2TimValueCallback<int>.fromJson(
        formatJson(await _channel.invokeMethod(
      'checkAbility',
      buildTimManagerParam(
        {},
      ),
    )));
  }

  @override
  Future<V2TimCallback> subscribeUserStatus({
    required List<String> userIDList,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'subscribeUserStatus',
      buildTimManagerParam(
        {
          "userIDList": userIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimCallback> unsubscribeUserStatus({
    required List<String> userIDList,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'unsubscribeUserStatus',
      buildTimManagerParam(
        {
          "userIDList": userIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    return V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(
        formatJson(await _channel.invokeMethod(
      'setConversationCustomData',
      buildConversationManagerParam(
        {
          "customData": customData,
          "conversationIDList": conversationIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationListByFilter({
    required V2TimConversationListFilter filter,
  }) async {
    return V2TimValueCallback<V2TimConversationResult>.fromJson(
        formatJson(await _channel.invokeMethod(
      'getConversationListByFilter',
      buildConversationManagerParam(
        {
          "filter": filter.toJson(),
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    return V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(
        formatJson(await _channel.invokeMethod(
      'markConversation',
      buildConversationManagerParam(
        {
          "markType": markType,
          "enableMark": enableMark,
          "conversationIDList": conversationIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(
        formatJson(await _channel.invokeMethod(
      'createConversationGroup',
      buildConversationManagerParam(
        {
          "groupName": groupName,
          "conversationIDList": conversationIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<String>>> getConversationGroupList() async {
    return V2TimValueCallback<List<String>>.fromJson(
        formatJson(await _channel.invokeMethod(
      'getConversationGroupList',
      buildConversationManagerParam(
        {},
      ),
    )));
  }

  @override
  Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'deleteConversationGroup',
      buildConversationManagerParam(
        {
          "groupName": groupName,
        },
      ),
    )));
  }

  @override
  Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    return V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'renameConversationGroup',
      buildConversationManagerParam(
        {
          "oldName": oldName,
          "newName": newName,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(
        formatJson(await _channel.invokeMethod(
      'addConversationsToGroup',
      buildConversationManagerParam(
        {
          "groupName": groupName,
          "conversationIDList": conversationIDList,
        },
      ),
    )));
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(
        formatJson(await _channel.invokeMethod(
      'deleteConversationsFromGroup',
      buildConversationManagerParam(
        {
          "groupName": groupName,
          "conversationIDList": conversationIDList,
        },
      ),
    )));
  }

  // 信令
  @override
  Future<void> addSignalingListener({
    required String listenerUuid,
    required V2TimSignalingListener listener,
  }) async {
    return _channel.invokeMethod(
        "addSignalingListener",
        buildSignalingManagerParam({
          "listenerUuid": listenerUuid,
        }));
  }

  @override
  Future<void> removeSignalingListener({
    required String listenerUuid,
    V2TimSignalingListener? listener,
  }) async {
    return _channel.invokeMethod(
        "removeSignalingListener",
        buildSignalingManagerParam({
          "listenerUuid": listenerUuid,
        }));
  }

  @override
  Future<V2TimValueCallback<String>> invite({
    required String invitee,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "invite",
          buildSignalingManagerParam(
            {
              "invitee": invitee,
              "data": data,
              "timeout": timeout,
              "onlineUserOnly": onlineUserOnly,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimValueCallback<String>> inviteInGroup({
    required String groupID,
    required List<String> inviteeList,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
  }) async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "inviteInGroup",
          buildSignalingManagerParam(
            {
              "groupID": groupID,
              "inviteeList": inviteeList,
              "data": data,
              "timeout": timeout,
              "onlineUserOnly": onlineUserOnly
            },
          ),
        ),
      ),
    );
  }
@override
  Future<V2TimCallback> cancel({
    required String inviteID,
    String? data,
  })async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "cancel",
          buildSignalingManagerParam(
            {
              "inviteID": inviteID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<V2TimCallback> accept({
    required String inviteID,
    String? data,
  })async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "accept",
          buildSignalingManagerParam(
            {
              "inviteID": inviteID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }
  @override
  Future<V2TimCallback> reject({
    required String inviteID,
    String? data,
  })async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "reject",
          buildSignalingManagerParam(
            {
              "inviteID": inviteID,
              "data": data,
            },
          ),
        ),
      ),
    );
  }
  @override
  Future<V2TimValueCallback<V2TimSignalingInfo>> getSignalingInfo({
    required String msgID,
  }) async {
    return V2TimValueCallback<V2TimSignalingInfo>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getSignalingInfo",
          buildSignalingManagerParam(
            {
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
  }
  @override
  Future<V2TimCallback> addInvitedSignaling({
    required V2TimSignalingInfo info,
  }) async {
     return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addInvitedSignaling",
          buildSignalingManagerParam(
            {
              "info": info.toJson(),
            },
          ),
        ),
      ),
    );
  }
  Map buildGroupManagerParam(Map param) {
    param["TIMManagerName"] = "groupManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  Map buildSignalingManagerParam(Map param) {
    param["TIMManagerName"] = "signalingManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  Map buildFriendManagerParam(Map param) {
    param["TIMManagerName"] = "friendshipManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  Map buildTimManagerParam(Map param) {
    param["TIMManagerName"] = "timManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  Map buildMessageMangerParam(Map param) {
    param["TIMManagerName"] = "messageManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  ///@nodoc
  Map buildConversationManagerParam(Map param) {
    param["TIMManagerName"] = "conversationManager";
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {}
    return param;
  }

  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
