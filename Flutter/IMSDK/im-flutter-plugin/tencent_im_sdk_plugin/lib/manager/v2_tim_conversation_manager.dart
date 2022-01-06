import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:uuid/uuid.dart';

/// 会话接口，包含了会话的获取，删除和更新的逻辑
///
/// [setConversationListener] 设置会话监听器
///
/// [getConversationList] 获取会话列表
///
/// [deleteConversation] 获取指定会话
///
/// [setConversationDraft] 删除会话
///
/// {@category Manager}
///
class V2TIMConversationManager {
  ///@nodoc
  late MethodChannel _channel;

  Map<String, V2TimConversationListener> conversationListenerList = {};

  ///@nodoc
  V2TIMConversationManager(channel) {
    this._channel = channel;
  }
  Future<void> setConversationListener({
    required V2TimConversationListener listener,
  }) {
    final String uuid = Uuid().v4();
    this.conversationListenerList[uuid] = listener;
    return ImFlutterPlatform.instance
        .setConversationListener(listener: listener, listenerUuid: uuid);
  }

  ///   获取会话列表
  /// ```
  ///   一个会话对应一个聊天窗口，比如跟一个好友的 1v1 聊天，或者一个聊天群，都是一个会话。
  ///   由于历史的会话数量可能很多，所以该接口希望您采用分页查询的方式进行调用。
  ///   该接口拉取的是本地缓存的会话，如果服务器会话有更新，SDK 内部会自动同步，然后在 V2TIMConversationListener 回调告知客户。
  ///   该接口获取的会话列表默认已经按照会话 lastMessage -> timestamp 做了排序，timestamp 越大，会话越靠前。
  ///   如果会话全部拉取完毕，成功回调里面 V2TIMConversationResult 中的 isFinished 获取字段值为 true。
  ///   最多能拉取到最近的5000个会话。
  /// ```
  /// 参数
  ///
  ///```
  /// nextSeq	分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
  /// count	分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
  /// ```
  ///
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    return ImFlutterPlatform.instance.getConversationList(
      nextSeq: nextSeq,
      count: count,
    );
  }

  /// 获取会话不格式化
  Future<LinkedHashMap<dynamic, dynamic>> getConversationListWithoutFormat({
    required String nextSeq,
    required int count,
  }) async {
    return await _channel.invokeMethod(
      "getConversationList",
      buildParam(
        {
          "nextSeq": nextSeq,
          "count": count,
        },
      ),
    );
  }

  /// 通过会话ID获取指定会话列表
  ///
  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    return ImFlutterPlatform.instance.getConversationListByConversaionIds(
        conversationIDList: conversationIDList);
  }

  /// 会话置顶
  ///
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    return ImFlutterPlatform.instance
        .pinConversation(conversationID: conversationID, isPinned: isPinned);
  }

  /// 获取会话未读总数
  ///
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    return ImFlutterPlatform.instance.getTotalUnreadMessageCount();
  }

  /// 获取指定会话
  ///
  /// 参数
  ///
  /// ```
  /// conversationID	会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
  ///
  /// ```
  ///
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    /*required*/ required String conversationID,
  }) async {
    return ImFlutterPlatform.instance
        .getConversation(conversationID: conversationID);
  }

  /// 删除会话
  ///
  /// 请注意:
  ///
  /// ```
  /// 删除会话会在本地删除的同时，在服务器也会同步删除。
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  /// ```
  ///
  Future<V2TimCallback> deleteConversation({
    /*required*/ required String conversationID,
  }) async {
    return ImFlutterPlatform.instance
        .deleteConversation(conversationID: conversationID);
  }

  /// 设置会话草稿
  ///
  /// ```
  /// 只在本地保存，不会存储 Server，不能多端同步，程序卸载重装会失效。
  /// ```
  /// 参数
  ///
  /// ```
  /// draftText	草稿内容, 为 null 则表示取消草稿
  /// ```
  ///
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    return ImFlutterPlatform.instance.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "conversationManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
