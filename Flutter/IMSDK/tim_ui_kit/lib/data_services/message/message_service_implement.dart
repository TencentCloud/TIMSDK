// ignore_for_file: deprecated_member_use

import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_message_read_member_list.dart';

class MessageServiceImpl extends MessageService {
  @override
  Future<List<V2TimMessage>> getHistoryMessageList({
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
    final List<V2TimMessage> messageList = res.data ?? [];
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
  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getGroupMessageReadMemberList(
            messageID: messageID,
            filter: filter,
            nextSeq: nextSeq,
            count: count);
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getMessageReadReceipts(messageIDList: messageIDList);
  }

  @override
  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessageReadReceipts(messageIDList: messageIDList);
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
  Future<V2TimMsgCreateInfoResult?> createCustomMessage(
      {required String data}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createCustomMessage(data: data);
    if (res.code == 0) {
      final messageResult = res.data;
      return messageResult;
    }
    return null;
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createFaceMessage(
      {required int index, required String data}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createFaceMessage(index: index, data: data);
    if (res.code == 0) {
      final messageResult = res.data;
      return messageResult;
    }
    return null;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage(
      {required String msgID, // 自己创建的ID
      bool? onlineUserOnly}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .reSendMessage(msgID: msgID, onlineUserOnly: onlineUserOnly ?? false);
    return res;
  }

  @override
  Future<V2TimMsgCreateInfoResult?> createTextAtMessage(
      {required String text, required List<String> atUserList}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createTextAtMessage(text: text, atUserList: atUserList);
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
  Future<V2TimValueCallback<V2TimMessage>> sendMessage({
    required String id, // 自己创建的ID
    required String receiver,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    bool needReadReceipt = false,
    OfflinePushInfo? offlinePushInfo,
    String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
    String? localCustomData,
  }) {
    return TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
          id: id,
          receiver: receiver,
          groupID: groupID,
          priority: priority,
          onlineUserOnly: onlineUserOnly,
          offlinePushInfo: offlinePushInfo,
          needReadReceipt: needReadReceipt,
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
    bool needReadReceipt = false,
    required V2TimMessage replyMessage, // 被回复的消息
  }) {
    return TencentImSDKPlugin.v2TIMManager.getMessageManager().sendReplyMessage(
        id: id,
        receiver: receiver,
        groupID: groupID,
        needReadReceipt: needReadReceipt,
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
  Future<V2TimMsgCreateInfoResult?> createLocationMessage(
      {required String desc,
      required double longitude,
      required double latitude}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createLocationMessage(
            desc: desc, longitude: longitude, latitude: latitude);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages(
      {required V2TimMessageSearchParam searchParam}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .searchLocalMessages(searchParam: searchParam);
    return res;
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

  @override
  Future<V2TimCallback> setLocalCustomInt(
      {required String msgID, required int localCustomInt}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .setLocalCustomInt(msgID: msgID, localCustomInt: localCustomInt);
    return res;
  }

  @override
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required ReceiveMsgOptEnum opt,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .setC2CReceiveMessageOpt(userIDList: userIDList, opt: opt);
  }

  @override
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required ReceiveMsgOptEnum opt,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .setGroupReceiveMessageOpt(groupID: groupID, opt: opt);
  }
}
