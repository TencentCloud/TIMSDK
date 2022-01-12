import 'package:discuss/config.dart';
import 'package:discuss/utils/generatetestusersig.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

GenerateTestUserSig generateTestUserSig = GenerateTestUserSig(
  sdkappid: IMDiscussConfig.sdkappid,
  key: IMDiscussConfig.key,
);

class IMSDK {
  static Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.login(
      userID: userID,
      userSig: userSig,
    );
    return res;
  }

  static Future<V2TimValueCallback<bool>> init({
    required V2TimSDKListener listener,
  }) async {
    V2TimValueCallback<bool> res =
        await TencentImSDKPlugin.v2TIMManager.initSDK(
      sdkAppID: IMDiscussConfig.sdkappid,
      loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
      listener: listener,
    );
    return res;
  }

  static void setGroupListener({
    required V2TimGroupListener listener,
  }) {
    TencentImSDKPlugin.v2TIMManager.setGroupListener(
      listener: listener,
    );
  }

  static void advancedMsgListener({
    required V2TimAdvancedMsgListener listener,
  }) {
    TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(
          listener: listener,
        );
  }

  static void setConversationListener({
    required V2TimConversationListener listener,
  }) {
    TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationListener(
          listener: listener,
        );
  }

  static void setFriendListener({
    required V2TimFriendshipListener listener,
  }) {
    TencentImSDKPlugin.v2TIMManager.getFriendshipManager().setFriendListener(
          listener: listener,
        );
  }

  static Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    V2TimValueCallback<List<V2TimUserFullInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: userIDList);
    return res;
  }

  static Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
      userFullInfo: userFullInfo,
    );
    return res;
  }

  static Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    V2TimValueCallback<int> res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getTotalUnreadMessageCount();
    return res;
  }

  static Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationList({
    String? nextSeq = "0",
    int? count = 100,
  }) async {
    V2TimValueCallback<V2TimConversationResult> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(
          nextSeq: nextSeq!,
          count: count!,
        );
    return res;
  }

  static Future<V2TimCallback> deleteConversation({
    required String conversationID,
  }) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(
          conversationID: conversationID,
        );
    return res;
  }

  static Future<V2TimValueCallback<V2TimConversation>> getConversation({
    required String conversationID,
  }) async {
    V2TimValueCallback<V2TimConversation> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(
          conversationID: conversationID,
        );
    return res;
  }

  static Future<V2TimValueCallback<List<V2TimMessage>>>
      getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getC2CHistoryMessageList(
          userID: userID,
          count: count,
          lastMsgID: lastMsgID,
        );
    return res;
  }

  static Future<V2TimValueCallback<List<V2TimMessage>>>
      getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getGroupHistoryMessageList(
          groupID: groupID,
          count: count,
          lastMsgID: lastMsgID,
        );
    return res;
  }
}
