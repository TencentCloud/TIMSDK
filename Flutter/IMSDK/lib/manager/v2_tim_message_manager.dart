import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/V2TimReceiveMessageOptInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

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
/// [sendVideoMessage] 创建视频消息（视频最大支持 100 MB）
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
  V2TimAdvancedMsgListener advancedMsgListener = new V2TimAdvancedMsgListener();

  ///@nodoc
  V2TIMMessageManager(channel) {
    this._channel = channel;
  }

  /// 添加高级消息的事件监听器
  ///
  void addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
  }) {
    advancedMsgListener = listener;
    _channel.invokeMethod("addAdvancedMsgListener", _buildParam({}));
  }

  /// 移除高级消息监听器
  ///
  void removeAdvancedMsgListener() {
    advancedMsgListener = new V2TimAdvancedMsgListener();
    _channel.invokeMethod("removeAdvancedMsgListener", _buildParam({}));
  }

  ///发送图片消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendImageMessage({
    required String imagePath,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendImageMessage",
          _buildParam(
            {
              "imagePath": imagePath,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  ///发送视频消息
  ///
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
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendVideoMessage",
          _buildParam(
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
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  ///发送自定义消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendTextMessage",
          _buildParam(
            {
              "text": text,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  ///发送自定义消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    String desc = "",
    String extension = "",
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendCustomMessage",
          _buildParam(
            {
              "data": data,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "desc": desc,
              "extension": extension,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  ///发送文件
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendFileMessage({
    required String filePath,
    required String fileName,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendFileMessage",
          _buildParam(
            {
              "filePath": filePath,
              "fileName": fileName,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  /// 发送语音消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage({
    required String soundPath,
    required String receiver,
    required String groupID,
    required int duration,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendSoundMessage",
          _buildParam(
            {
              "soundPath": soundPath,
              "receiver": receiver,
              "duration": duration,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
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
  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage({
    required String text,
    required List<String> atUserList,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendTextAtMessage',
          _buildParam(
            {
              "text": text,
              "atUserList": atUserList,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  /// 发送地理位置消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendLocationMessage',
          _buildParam(
            {
              "desc": desc,
              "longitude": longitude,
              "latitude": latitude,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  /// 创建表情消息
  ///
  /// SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引， 或者直接使用 data 存储表情二进制信息以及字符串 key，都由用户自定义，SDK 内部只做透传。
  ///
  /// 参数
  /// index	表情索引
  /// data	自定义数据
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage({
    required int index,
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendFaceMessage',
          _buildParam(
            {
              "index": index,
              "data": data,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
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
  Future<V2TimValueCallback<V2TimMessage>> sendMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendMergerMessage',
          _buildParam(
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
              "offlinePushInfo": offlinePushInfo?.toJson(),
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
  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage({
    required String msgID,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendForwardMessage',
          _buildParam(
            {
              "msgID": msgID,
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo?.toJson(),
            },
          ),
        ),
      ),
    );
  }

  /// 消息重发
  ///
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage({
    required String msgID,
    bool onlineUserOnly = false,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "reSendMessage",
          _buildParam(
            {
              "msgID": msgID,
              "onlineUserOnly": onlineUserOnly,
            },
          ),
        ),
      ),
    );
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
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setC2CReceiveMessageOpt",
          _buildParam(
            {
              "userIDList": userIDList,
              "opt": opt,
            },
          ),
        ),
      ),
    );
  }

  ///获取用户消息接收选项
  ///
  ///
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getC2CReceiveMessageOpt",
          _buildParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
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
    required int opt,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupReceiveMessageOpt",
          _buildParam(
            {
              "groupID": groupID,
              "opt": opt,
            },
          ),
        ),
      ),
    );
  }

  /// 设置消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
  ///
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setLocalCustomData",
          _buildParam(
            {
              "localCustomData": localCustomData,
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
  }

  /// 设置消息自定义数据，可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
  ///
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setLocalCustomInt",
          _buildParam(
            {
              "msgID": msgID,
              "localCustomInt": localCustomInt,
            },
          ),
        ),
      ),
    );
  }

  /// 设置云端自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）
  ///
  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setCloudCustomData",
          _buildParam(
            {
              "msgID": msgID,
              "data": data,
            },
          ),
        ),
      ),
    );
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
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getC2CHistoryMessageList",
          _buildParam(
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
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupHistoryMessageList",
          _buildParam(
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

  /// 撤回消息
  ///
  /// 注意
  ///
  /// ```
  /// 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 控制台（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
  /// 仅支持单聊和群组中发送的普通消息，无法撤销 onlineUserOnly 为 true 即仅在线用户才能收到的消息，也无法撤销直播群（AVChatRoom）中的消息。
  /// 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
  /// ```
  ///
  Future<V2TimCallback> revokeMessage({
    required String msgID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "revokeMessage",
          _buildParam(
            {
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
  }

  ///设置单聊消息已读
  ///
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markC2CMessageAsRead",
          _buildParam(
            {
              "userID": userID,
            },
          ),
        ),
      ),
    );
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
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    return V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getHistoryMessageList",
          _buildParam(
            {
              "getType": getType,
              "userID": userID,
              "groupID": groupID,
              'lastMsgSeq': lastMsgSeq,
              "count": count,
              "lastMsgID": lastMsgID,
            },
          ),
        ),
      ),
    );
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
      _buildParam(
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

  /// 设置群组消息已读
  ///
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markGroupMessageAsRead",
          _buildParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  /// 删除本地消息
  ///
  /// 注意
  ///
  /// ```
  /// 消息只能本地删除，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到， 但是如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
  /// ```
  ///
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessageFromLocalStorage",
          _buildParam(
            {
              "msgID": msgID,
            },
          ),
        ),
      ),
    );
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
  Future<V2TimCallback> deleteMessages({
    required List<String> msgIDs,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessages",
          _buildParam(
            {
              "msgIDs": msgIDs,
            },
          ),
        ),
      ),
    );
  }

  ///向群组消息列表中添加一条消息
  ///
  ///该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
  ///
  ///返回[V2TimMessage]
  ///
  ///通过该接口 save 的消息只存本地，程序卸载后会丢失。
  ///
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertGroupMessageToLocalStorage",
          _buildParam(
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

  ///向C2C消息列表中添加一条消息
  ///
  ///该接口主要用于满足向C2C聊天会话中插入一些提示性消息的需求，比如“您已成功发送消息”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertC2CMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
  ///
  ///返回[V2TimMessage]
  ///
  ///通过该接口 save 的消息只存本地，程序卸载后会丢失。
  ///
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    return V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertC2CMessageToLocalStorage",
          _buildParam(
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
