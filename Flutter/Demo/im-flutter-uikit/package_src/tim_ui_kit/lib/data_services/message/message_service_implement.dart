import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MessageServiceImpl extends MessageService {
  @override
  Future<List<V2TimMessage>?> getHistoryMessageList({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getHistoryMessageList(
            count: count,
            getType: getType,
            userID: userID,
            groupID: groupID,
            lastMsgID: lastMsgID,
            lastMsgSeq: lastMsgSeq);
    final messageList = res.data;
    return messageList;
  }

  @override
  Future addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .addSimpleMsgListener(listener: listener);
  }

  @override
  Future<void> removeSimpleMsgListener({V2TimSimpleMsgListener? listener}) {
    return TencentImSDKPlugin.v2TIMManager
        .removeSimpleMsgListener(listener: listener);
  }

  @override
  Future<void> addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .addAdvancedMsgListener(listener: listener);
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createTextMessage(
      {required String text}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createTextMessage(text: text);
    if (res.code == 0) {
      final messageResult = res.data;
      return messageResult;
    }
    return null;
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createImageMessage({
    required String imagePath,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createImageMessage(imagePath: imagePath);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createSoundMessage(soundPath: soundPath, duration: duration);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id, // 自己创建的ID
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData}) {
    return TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
          id: id,
          receiver: receiver,
          groupID: groupID,
          priority: priority,
          onlineUserOnly: onlineUserOnly,
        );
  }

  @override
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessageFromLocalStorage(msgID: msgID);
  }

  @override
  Future<V2TimCallback> revokeMessage({required String msgID}) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .revokeMessage(msgID: msgID);
  }

  @override
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .clearC2CHistoryMessage(userID: userID);
  }

  @override
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .clearGroupHistoryMessage(groupID: groupID);
  }

  @override
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markC2CMessageAsRead(userID: userID);
  }

  @override
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markGroupMessageAsRead(groupID: groupID);
  }

  @override
  Future<void> removeAdvancedMsgListener({V2TimAdvancedMsgListener? listener}) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .removeAdvancedMsgListener(listener: listener);
  }

  @override
  Future<List<V2TimMessage>?> downloadMergerMessage({
    required String msgID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .downloadMergerMessage(msgID: msgID);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createForwardMessage({
    required String msgID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createForwardMessage(msgID: msgID);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createMergerMessage(
            msgIDList: msgIDList,
            title: title,
            abstractList: abstractList,
            compatibleText: compatibleText);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimCallback> deleteMessages(
      {required List<String> msgIDs, List<dynamic>? webMessageInstanceList}) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessages(msgIDs: msgIDs);
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createVideoMessage(
      {required String videoPath,
      required String type,
      required int duration,
      required String snapshotPath}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createVideoMessage(
          videoFilePath: videoPath,
          type: type,
          duration: duration,
          snapshotPath: snapshotPath,
        );
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendReplyMessage({
    required String id, // 自己创建的ID
    required String receiver,
    required String groupID,
    required V2TimMessage replyMessage, // 被回复的消息
  }) {
    return TencentImSDKPlugin.v2TIMManager.getMessageManager().sendReplyMessage(
        id: id,
        receiver: receiver,
        groupID: groupID,
        replyMessage: replyMessage);
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createFileMessage(
      {required String filePath, required String fileName}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createFileMessage(filePath: filePath, fileName: fileName);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<List<V2TimMessage>?> findMessages({
    required List<String> messageIDList,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .findMessages(messageIDList: messageIDList);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }
}
