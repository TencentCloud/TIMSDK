import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_message_read_member_list.dart';

abstract class MessageService {
  Future<List<V2TimMessage>> getHistoryMessageList({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq,
    required int count,
    String? lastMsgID,
  });

  Future addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  });

  Future addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
  });

  Future<void> removeSimpleMsgListener({V2TimSimpleMsgListener? listener});

  Future<V2TimMsgCreateInfoResult?> createTextMessage({required String text});
  Future<V2TimMsgCreateInfoResult?> createFaceMessage(
      {required int index, required String data});

  Future<V2TimMsgCreateInfoResult?> createCustomMessage({required String data});

  Future<V2TimMsgCreateInfoResult?> createTextAtMessage(
      {required String text, required List<String> atUserList});

  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id, // 自己创建的ID
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      bool needReadReceipt = false,
      OfflinePushInfo? offlinePushInfo,
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData});

  Future<V2TimValueCallback<V2TimMessage>> sendReplyMessage({
    required String id, // 自己创建的ID
    required String receiver,
    required String groupID,
    bool needReadReceipt = false,
    required V2TimMessage replyMessage, // 被回复的消息
  });

  Future<V2TimValueCallback<V2TimMessage>> reSendMessage(
      {required String msgID, // 自己创建的ID
      bool onlineUserOnly});
  Future<V2TimMsgCreateInfoResult?> createImageMessage({
    required String imagePath,
  });

  Future<V2TimMsgCreateInfoResult?> createVideoMessage(
      {required String videoPath,
      required String type,
      required int duration,
      required String snapshotPath});

  Future<V2TimMsgCreateInfoResult?> createFileMessage({
    required String filePath,
    required String fileName,
  });

  Future<V2TimMsgCreateInfoResult?> createLocationMessage(
      {required String desc,
      required double longitude,
      required double latitude});

  Future<V2TimMsgCreateInfoResult?> createSoundMessage({
    required String soundPath,
    required int duration,
  });

  Future<V2TimMsgCreateInfoResult?> createForwardMessage({
    required String msgID,
  });

  Future<V2TimMsgCreateInfoResult?> createMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
  });

  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  });

  Future<V2TimCallback> revokeMessage({required String msgID});

  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  });

  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  });

  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  });

  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  });

  Future<void> removeAdvancedMsgListener({V2TimAdvancedMsgListener? listener});

  Future<List<V2TimMessage>?> downloadMergerMessage({
    required String msgID,
  });

  Future<V2TimCallback> deleteMessages(
      {required List<String> msgIDs, List<dynamic>? webMessageInstanceList});

  Future<List<V2TimMessage>?> findMessages({
    required List<String> messageIDList,
  });

  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  });

  Future<V2TimCallback> setLocalCustomInt(
      {required String msgID, required int localCustomInt});

  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required ReceiveMsgOptEnum opt,
  });

  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required ReceiveMsgOptEnum opt,
  });

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  });

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  });

  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  });
}
