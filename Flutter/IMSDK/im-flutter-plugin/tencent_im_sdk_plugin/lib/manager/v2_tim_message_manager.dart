import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/utils.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_msg_create_info_result.dart';
import 'package:uuid/uuid.dart';

///提供高级消息处理相关接口
///
/// [addAdvancedMsgListener] 添加高级消息的事件监听器
///
/// [removeAdvancedMsgListener] 移除高级消息监听器
///
/// [sendCustomMessage] 创建自定义消息
///
/// [sendImageMessage] 创建图片消息（图片最大支持 28 MB）
///
/// [sendSoundMessage] 创建语音消息（语音最大支持 28 MB）
///
/// [createVideoMessage] 创建视频消息（视频最大支持 100 MB）
///
/// [sendVideoMessage] 创建文件消息（文件最大支持 100 MB）
///
/// [getC2CHistoryMessageList] 获取单聊历史消息
///
/// [getGroupHistoryMessageList] 获取群组历史消息
///
/// [getHistoryMessageList] 获取历史消息高级接口
///
/// [revokeMessage] 撤回消息
///
/// [markC2CMessageAsRead] 设置单聊消息已读
///
/// [markGroupMessageAsRead] 设置群组消息已读
///
/// [deleteMessageFromLocalStorage] 删除本地消息
///
/// [deleteMessages] 删除本地及漫游消息
///
///{@category Manager}
///
class V2TIMMessageManager {
  ///@nodoc
  late MethodChannel _channel;

  ///@nodoc
  late Map<String, V2TimAdvancedMsgListener> advancedMsgListenerList = {};

  ///@nodoc
  V2TIMMessageManager(channel) {
    this._channel = channel;
  }

  /// 添加高级消息的事件监听器
  ///
  Future<void> addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
  }) {
    final String uuid = Uuid().v4();
    this.advancedMsgListenerList[uuid] = listener;
    return ImFlutterPlatform.instance
        .addAdvancedMsgListener(listener: listener, listenerUuid: uuid);
  }

  /// 移除高级消息监听器
  ///
  Future<void> removeAdvancedMsgListener({V2TimAdvancedMsgListener? listener}) {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = this.advancedMsgListenerList.keys.firstWhere(
          (k) => this.advancedMsgListenerList[k] == listener,
          orElse: () => "");
      this.advancedMsgListenerList.remove(listenerUuid);
    } else {
      this.advancedMsgListenerList.clear();
    }
    return ImFlutterPlatform.instance.removeAdvancedMsgListener(
      listenerUuid: listenerUuid,
    );
  }

  ///发送图片消息
  ///
  ///web 端发送图片消息时需要传入fileName、fileContent 字段
  ///
  @Deprecated(
      'sendImageMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createImageMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendImageMessage(
      {required String imagePath,
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      String? fileName,
      Uint8List? fileContent}) async {
    return ImFlutterPlatform.instance.sendImageMessage(
        imagePath: imagePath,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson(),
        fileName: fileName,
        fileContent: fileContent);
  }

  ///发送视频消息
  ///
  ///web 端发送视频消息时需要传入fileName, fileContent字段
  ///不支持 snapshotPath、duration、type
  ///
  @Deprecated(
      'sendVideoMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createVideoMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendVideoMessage({
    required String videoFilePath,
    required String receiver,
    required String type,
    required String snapshotPath,
    required int duration,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
    String? fileName,
    Uint8List? fileContent,
  }) async {
    return ImFlutterPlatform.instance.sendVideoMessage(
      videoFilePath: videoFilePath,
      receiver: receiver,
      type: type,
      snapshotPath: snapshotPath,
      duration: duration,
      groupID: groupID,
      priority: EnumUtils.convertMessagePriorityEnum(priority),
      onlineUserOnly: onlineUserOnly,
      isExcludedFromUnreadCount: isExcludedFromUnreadCount,
      offlinePushInfo: offlinePushInfo?.toJson(),
      fileName: fileName,
      fileContent: fileContent,
    );
  }

  /// 创建文本消息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage(
      {required String text}) async {
    return ImFlutterPlatform.instance.createTextMessage(text: text);
  }

  /// 创建定制化消息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage({
    required String data,
    String desc = "",
    String extension = "",
  }) async {
    return ImFlutterPlatform.instance
        .createCustomMessage(data: data, extension: extension, desc: desc);
  }

  /// 创建图片消息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage(
      {required String imagePath,
      Uint8List? fileContent, // web 必填
      String? fileName //web必填写
      }) async {
    return ImFlutterPlatform.instance.createImageMessage(
        imagePath: imagePath, fileContent: fileContent, fileName: fileName);
  }

  // 创建音频文件
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    return ImFlutterPlatform.instance
        .createSoundMessage(soundPath: soundPath, duration: duration);
  }

  /// 创建视频文件
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage({
    required String videoFilePath,
    required String type,
    required int duration,
    required String snapshotPath,
    String? fileName,
    Uint8List? fileContent,
  }) async {
    return ImFlutterPlatform.instance.createVideoMessage(
      videoFilePath: videoFilePath,
      type: type,
      duration: duration,
      snapshotPath: snapshotPath,
      fileName: fileName,
      fileContent: fileContent,
    );
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    return ImFlutterPlatform.instance.createTextAtMessage(
      text: text,
      atUserList: atUserList,
    );
  }

  /// 发送文件消息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage(
      {required String filePath,
      required String fileName,
      Uint8List? fileContent}) async {
    return ImFlutterPlatform.instance.createFileMessage(
        filePath: filePath, fileName: fileName, fileContent: fileContent);
  }

  /// 创建位置信息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    return ImFlutterPlatform.instance.createLocationMessage(
      desc: desc,
      longitude: longitude,
      latitude: latitude,
    );
  }

  /// 发送消息
  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id, // 自己创建的ID
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData}) async {
    return ImFlutterPlatform.instance.sendMessage(
        id: id,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson(),
        localCustomData: localCustomData,
        cloudCustomData: cloudCustomData);
  }

  String _getAbstractMessage(V2TimMessage message) {
    final abstractMap = {
      MessageElemType.V2TIM_ELEM_TYPE_FACE: "[表情消息]",
      MessageElemType.V2TIM_ELEM_TYPE_CUSTOM: "[自定义消息]",
      MessageElemType.V2TIM_ELEM_TYPE_FILE: "[文件消息]",
      MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS: "[群消息]",
      MessageElemType.V2TIM_ELEM_TYPE_IMAGE: "[图片消息]",
      MessageElemType.V2TIM_ELEM_TYPE_LOCATION: "[位置消息]",
      MessageElemType.V2TIM_ELEM_TYPE_MERGER: "[合并消息]",
      MessageElemType.V2TIM_ELEM_TYPE_NONE: "[没有元素]",
      MessageElemType.V2TIM_ELEM_TYPE_SOUND: "[语音消息]",
      MessageElemType.V2TIM_ELEM_TYPE_TEXT: "[文本消息]",
      MessageElemType.V2TIM_ELEM_TYPE_VIDEO: "[视频消息]",
    };

    return abstractMap[message.elemType] ?? "";
  }

  /// 发送回复消息
  Future<V2TimValueCallback<V2TimMessage>> sendReplyMessage(
      {required String id, // 自己创建的ID
      required String receiver,
      required String groupID,
      required V2TimMessage replyMessage, // 被回复的消息
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      String? localCustomData}) async {
    final cloudCustomData = {
      "messageReply": {
        "messageID": replyMessage.msgID,
        "messageAbstract": _getAbstractMessage(replyMessage),
        "messageSender": replyMessage.nickName != ""
            ? replyMessage.nickName
            : replyMessage.sender,
        "messageType": replyMessage.elemType,
        "version": 1
      }
    };

    return ImFlutterPlatform.instance.sendMessage(
        id: id,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson(),
        localCustomData: localCustomData,
        cloudCustomData: json.encode(cloudCustomData));
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    return ImFlutterPlatform.instance.createFaceMessage(
      index: index,
      data: data,
    );
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
  }) async {
    return ImFlutterPlatform.instance.createMergerMessage(
        msgIDList: msgIDList,
        title: title,
        abstractList: abstractList,
        compatibleText: compatibleText);
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID, String? webMessageInstance}) async {
    return ImFlutterPlatform.instance.createForwardMessage(
        msgID: msgID, webMessageInstance: webMessageInstance);
  }

  @Deprecated(
      'sendTextMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createTextMessage创建消息,再调用sendMessage发送消息')

  ///发送高级文本消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String receiver,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return ImFlutterPlatform.instance.sendTextMessage(
      text: text,
      receiver: receiver,
      groupID: groupID,
      priority: EnumUtils.convertMessagePriorityEnum(priority),
      onlineUserOnly: onlineUserOnly,
      isExcludedFromUnreadCount: isExcludedFromUnreadCount,
      offlinePushInfo: offlinePushInfo?.toJson(),
    );
  }

  ///发送自定义消息
  ///
  @Deprecated(
      'sendCustomMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createCustomMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String data,
    required String receiver,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    String desc = "",
    String extension = "",
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return ImFlutterPlatform.instance.sendCustomMessage(
        data: data,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        desc: desc,
        extension: extension,
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson());
  }

  ///发送文件
  /// web 端 fileName、fileContent 为必传字段
  @Deprecated(
      'sendFileMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createFileMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendFileMessage(
      {required String filePath,
      required String fileName,
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      Uint8List? fileContent}) async {
    return ImFlutterPlatform.instance.sendFileMessage(
        filePath: filePath,
        fileName: fileName,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson(),
        fileContent: fileContent);
  }

  /// 发送语音消息
  ///
  /// 注意： web不支持该接口
  ///
  @Deprecated(
      'sendSoundMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createSoundMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage({
    required String soundPath,
    required String receiver,
    required String groupID,
    required int duration,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return ImFlutterPlatform.instance.sendSoundMessage(
        soundPath: soundPath,
        receiver: receiver,
        groupID: groupID,
        duration: duration,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson());
  }

  /// 创建文本消息，并且可以附带 @ 提醒功能
  ///
  /// 提醒消息仅适用于在群组中发送的消息
  ///
  /// 参数
  /// atUserList	需要 @ 的用户列表，如果需要 @ALL，请传入 AT_ALL_TAG 常量字符串。 举个例子，假设该条文本消息希望@提醒 denny 和 lucy 两个用户，同时又希望@所有人，atUserList 传 ["denny","lucy",AT_ALL_TAG]
  /// 注意
  /// atUserList 使用注意事项
  /// 默认情况下，最多支持 @ 30个用户，超过限制后，消息会发送失败。
  /// atUserList 的总数不能超过默认最大数，包括 @ALL。
  ///
  @Deprecated(
      'sendTextAtMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createTextAtMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage({
    required String text,
    required List<String> atUserList,
    required String receiver,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return await ImFlutterPlatform.instance.sendTextAtMessage(
      text: text,
      receiver: receiver,
      groupID: groupID,
      atUserList: atUserList,
      priority: EnumUtils.convertMessagePriorityEnum(priority),
      onlineUserOnly: onlineUserOnly,
      isExcludedFromUnreadCount: isExcludedFromUnreadCount,
      offlinePushInfo: offlinePushInfo?.toJson(),
    );
  }

  /// 发送地理位置消息
  @Deprecated(
      'sendLocationMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createLocationMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
    required String receiver,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return await ImFlutterPlatform.instance.sendLocationMessage(
        desc: desc,
        longitude: longitude,
        latitude: latitude,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson());
  }

  /// 创建表情消息
  ///
  /// SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引， 或者直接使用 data 存储表情二进制信息以及字符串 key，都由用户自定义，SDK 内部只做透传。
  ///
  /// 参数
  /// index	表情索引
  /// data	自定义数据
  ///
  @Deprecated(
      'sendFaceMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createFaceMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage({
    required int index,
    required String data,
    required String receiver,
    required String groupID,
    MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return await ImFlutterPlatform.instance.sendFaceMessage(
        index: index,
        data: data,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson());
  }

  /// 合并消息
  ///
  /// 我们在收到一条合并消息的时候，通常会在聊天界面这样显示：
  ///
  /// |vinson 和 lynx 的聊天记录 | – title （标题）
  ///
  /// |vinson：新版本 SDK 计划什么时候上线呢？ | – abstract1 （摘要信息1）
  ///
  /// |lynx：计划下周一，具体时间要看下这两天的系统测试情况.. | – abstract2 （摘要信息2）
  ///
  /// |vinson：好的. | – abstract3 （摘要信息3）
  ///
  /// 聊天界面通常只会展示合并消息的标题和摘要信息，完整的转发消息列表，需要用户主动点击转发消息 UI 后再获取。
  ///
  /// 多条被转发的消息可以被创建成一条合并消息 V2TIMMessage，然后调用 sendMessage 接口发送，实现步骤如下：
  ///
  /// 1. 调用 createMergerMessage 创建一条合并消息 V2TIMMessage。
  ///
  /// 2. 调用 sendMessage 发送转发消息 V2TIMMessage。
  ///
  /// 收到合并消息解析步骤：
  ///
  /// 1. 通过 V2TIMMessage 获取 mergerElem。
  ///
  /// 2. 通过 mergerElem 获取 title 和 abstractList UI 展示。
  ///
  /// 3. 当用户点击摘要信息 UI 的时候，调用 downloadMessageList 接口获取转发消息列表。
  ///
  ///
  /// 注意
  /// web 端使用时必须传入webMessageInstanceList 字段。 在web端返回的消息实例会包含该字段
  ///
  @Deprecated(
      'sendMergerMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createMergerMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      List<String>? webMessageInstanceList}) async {
    return await ImFlutterPlatform.instance.sendMergerMessage(
        msgIDList: msgIDList,
        title: title,
        abstractList: abstractList,
        compatibleText: compatibleText,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson(),
        webMessageInstanceList: webMessageInstanceList);
  }

  /// 获取合并消息的子消息
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage({
    required String msgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'downloadMergerMessage',
          _buildParam(
            {
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
  }

  /// 转发消息
  ///
  /// 如果需要转发一条消息，不能直接调用 sendMessage 接口发送原消息，需要先 createForwardMessage 创建一条转发消息再发送。
  ///
  /// 参数
  /// message	待转发的消息对象，消息状态必须为 V2TIM_MSG_STATUS_SEND_SUCC，消息类型不能为 V2TIMGroupTipsElem。
  /// 返回
  /// 转发消息对象，elem 内容和原消息完全一致。
  ///
  /// 注意
  /// web 端使用时必须传入webMessageInstance 字段。 在web端返回的消息实例会包含该字段
  ///
  @Deprecated(
      'sendForwardMessage自3.6.0开始弃用，我们将创建消息与发送消息分离，请先使用createForwardMessage创建消息,再调用sendMessage发送消息')
  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage(
      {required String msgID,
      required String receiver,
      required String groupID,
      MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      OfflinePushInfo? offlinePushInfo,
      String? webMessageInstance}) async {
    return await ImFlutterPlatform.instance.sendForwardMessage(
        msgID: msgID,
        receiver: receiver,
        groupID: groupID,
        priority: EnumUtils.convertMessagePriorityEnum(priority),
        onlineUserOnly: onlineUserOnly,
        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
        offlinePushInfo: offlinePushInfo?.toJson(),
        webMessageInstance: webMessageInstance);
  }

  /// 消息重发
  ///
  ///注意
  ///web 端使用时webMessageInstatnce 为必传
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage(
      {required String msgID,
      bool onlineUserOnly = false,
      Object? webMessageInstatnce}) async {
    return await ImFlutterPlatform.instance.reSendMessage(msgID: msgID);
  }

  /// 设置用户消息接收选项
  ///
  /// 注意
  /// 请注意:
  /// userIDList 一次最大允许设置 30 个用户。
  /// 该接口调用频率限制为 1s 1次，超过频率限制会报错。
  /// 参数
  /// opt	三种类型的消息接收选项： 0,V2TIMMessage.V2TIM_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知 1, V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE：不会接收到消息 2,V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required ReceiveMsgOptEnum opt,
  }) async {
    return await ImFlutterPlatform.instance.setC2CReceiveMessageOpt(
        userIDList: userIDList, opt: EnumUtils.convertReceiveMsgOptEnum(opt));
  }

  ///查询针对某个用户的 C2C 消息接收选项
  ///
  ///注意： web不支持该接口
  ///
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    return await ImFlutterPlatform.instance
        .getC2CReceiveMessageOpt(userIDList: userIDList);
  }

  /// 修改群消息接收选项
  ///
  /// 参数
  /// opt	三种类型的消息接收选项： V2TIMMessage.V2TIM_GROUP_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知 V
  /// 2TIMMessage.V2TIM_GROUP_NOT_RECEIVE_MESSAGE：不会接收到群消息
  /// V2TIMMessage.V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知
  ///
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required ReceiveMsgOptEnum opt,
  }) async {
    return await ImFlutterPlatform.instance.setGroupReceiveMessageOpt(
      groupID: groupID,
      opt: EnumUtils.convertReceiveMsgOptEnum(opt),
    );
  }

  /// 设置消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
  ///
  /// 注意： web不支持该接口
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    return ImFlutterPlatform.instance
        .setLocalCustomData(msgID: msgID, localCustomData: localCustomData);
  }

  /// 设置消息自定义数据，可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
  ///
  ///web 不支持
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    return ImFlutterPlatform.instance
        .setLocalCustomInt(msgID: msgID, localCustomInt: localCustomInt);
  }

  /// 设置云端自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）
  ///
  ///web 不支持
  @Deprecated('已弃用，请在创建消息时使用自定义数据')
  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    return ImFlutterPlatform.instance
        .setCloudCustomData(data: data, msgID: msgID);
  }

  /// 获取单聊历史消息
  ///
  /// 参数
  ///
  /// ```
  /// count	拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
  /// lastMsg	获取消息的起始消息，如果传 null，起始消息为会话的最新消息
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 如果 SDK 检测到没有网络，默认会直接返回本地数据
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    return ImFlutterPlatform.instance.getC2CHistoryMessageList(
        userID: userID, count: count, lastMsgID: lastMsgID);
  }

  /// 获取群组历史消息
  ///
  /// 参数
  ///
  /// ```
  /// count	拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
  /// lastMsg	获取消息的起始消息，如果传 null，起始消息为会话的最新消息
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 如果 SDK 检测到没有网络，默认会直接返回本地数据
  /// 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    return ImFlutterPlatform.instance.getGroupHistoryMessageList(
        groupID: groupID, count: count, lastMsgID: lastMsgID);
  }

  /// 撤回消息
  ///
  /// 注意
  ///
  /// ```
  /// 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 控制台（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
  /// 仅支持单聊和群组中发送的普通消息，无法撤销 onlineUserOnly 为 true 即仅在线用户才能收到的消息，也无法撤销直播群（AVChatRoom）中的消息。
  /// 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
  ///
  ///
  /// web 端掉用 webMessageInstatnce 为必传
  /// ```
  ///
  Future<V2TimCallback> revokeMessage(
      {required String msgID, Object? webMessageInstatnce}) async {
    return ImFlutterPlatform.instance
        .revokeMessage(msgID: msgID, webMessageInstatnce: webMessageInstatnce);
  }

  ///设置单聊消息已读
  ///
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    return ImFlutterPlatform.instance.markC2CMessageAsRead(userID: userID);
  }

  /// 获取历史消息高级接口
  ///
  /// 参数
  /// option	拉取消息选项设置，可以设置从云端、本地拉取更老或更新的消息
  ///
  /// 请注意：
  /// 如果设置为拉取云端消息，当 SDK 检测到没有网络，默认会直接返回本地数据
  /// 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
  ///
  ///web 端使用该接口，消息都是从远端拉取，不支持lastMsgSeq
  ///
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    return ImFlutterPlatform.instance.getHistoryMessageList(
        getType: EnumUtils.convertHistoryMsgGetTypeEnum(getType),
        userID: userID,
        count: count,
        lastMsgID: lastMsgID,
        groupID: groupID,
        lastMsgSeq: lastMsgSeq);
  }

  /// 获取历史消息高级接口(没有处理Native返回数据)
  ///
  /// 参数
  /// option	拉取消息选项设置，可以设置从云端、本地拉取更老或更新的消息
  ///
  /// 请注意：
  /// 如果设置为拉取云端消息，当 SDK 检测到没有网络，默认会直接返回本地数据
  /// 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
  ///
  /// 注意： web不支持该接口
  ///
  Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    return ImFlutterPlatform.instance.getHistoryMessageListWithoutFormat(
        count: count,
        getType: EnumUtils.convertHistoryMsgGetTypeEnum(getType),
        userID: userID,
        groupID: groupID,
        lastMsgSeq: lastMsgSeq,
        lastMsgID: lastMsgID);
  }

  /// 设置群组消息已读
  ///
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    return ImFlutterPlatform.instance.markGroupMessageAsRead(groupID: groupID);
  }

  /// 删除本地消息
  ///
  /// 注意
  ///
  /// ```
  /// 消息只能本地删除，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到， 但是如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
  /// ```
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    return ImFlutterPlatform.instance
        .deleteMessageFromLocalStorage(msgID: msgID);
  }

  /// 删除本地及漫游消息
  ///
  /// 注意
  ///
  /// ```
  ///该接口会删除本地历史的同时也会把漫游消息即保存在服务器上的消息也删除，卸载重装后无法再拉取到。需要注意的是：
  ///   一次最多只能删除 30 条消息
  ///   要删除的消息必须属于同一会话
  ///   一秒钟最多只能调用一次该接口
  ///   如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
  /// ```
  ///
  Future<V2TimCallback> deleteMessages(
      {required List<String> msgIDs,
      List<dynamic>? webMessageInstanceList}) async {
    return ImFlutterPlatform.instance.deleteMessages(
        msgIDs: msgIDs, webMessageInstanceList: webMessageInstanceList);
  }

  ///向群组消息列表中添加一条消息
  ///
  ///该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
  ///
  ///返回[V2TimMessage]
  ///
  ///通过该接口 save 的消息只存本地，程序卸载后会丢失。
  ///
  ///注意： web不支持该接口
  ///
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return ImFlutterPlatform.instance.insertGroupMessageToLocalStorage(
        data: data, groupID: groupID, sender: sender);
  }

  ///向C2C消息列表中添加一条消息
  ///
  ///该接口主要用于满足向C2C聊天会话中插入一些提示性消息的需求，比如“您已成功发送消息”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertC2CMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
  ///
  ///返回[V2TimMessage]
  ///
  ///通过该接口 save 的消息只存本地，程序卸载后会丢失。
  ///
  ///注意： web不支持该接口
  ///
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return await ImFlutterPlatform.instance.insertC2CMessageToLocalStorage(
        data: data, userID: userID, sender: sender);
  }

  /// 清空单聊本地及云端的消息（不删除会话）
  ///
  /// 5.4.666 及以上版本支持
  ///
  /// 注意
  /// 请注意：
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    return await ImFlutterPlatform.instance
        .clearC2CHistoryMessage(userID: userID);
  }

  /// 清空群聊本地及云端的消息（不删除会话）
  ///
  /// 5.4.666 及以上版本支持
  ///
  /// 注意
  /// 请注意：
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    return await ImFlutterPlatform.instance
        .clearGroupHistoryMessage(groupID: groupID);
  }

  ///标记所有消息为已读
  ///5.8及其以上版本支持
  Future<V2TimCallback> markAllMessageAsRead() async {
    return await ImFlutterPlatform.instance.markAllMessageAsRead();
  }

  /// 搜索本地消息
  ///
  /// 注意： web不支持该接口
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    return await ImFlutterPlatform.instance
        .searchLocalMessages(searchParam: searchParam);
  }

  /// 根据 messageID 查询指定会话中的本地消息
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    return await ImFlutterPlatform.instance
        .findMessages(messageIDList: messageIDList);
  }

  ///@nodoc
  Map _buildParam(Map param) {
    param["TIMManagerName"] = "messageManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
