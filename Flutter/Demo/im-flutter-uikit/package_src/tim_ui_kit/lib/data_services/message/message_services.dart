import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

abstract class MessageService {
  Future<List<V2TimMessage>?> getHistoryMessageList({
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

  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id, // 自己创建的ID
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData});

  Future<V2TimValueCallback<V2TimMessage>> sendReplyMessage({
    required String id, // 自己创建的ID
    required String receiver,
    required String groupID,
    required V2TimMessage replyMessage, // 被回复的消息
  });

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
}
