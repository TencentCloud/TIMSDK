// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TIMUIKitChatController {
  late TUIChatSeparateViewModel? model;
  final TUIChatGlobalModel globalChatModel =
      serviceLocator<TUIChatGlobalModel>();

  TIMUIKitChatController({TUIChatSeparateViewModel? viewModel}) {
    if (viewModel != null) {
      model = viewModel;
    }
  }

  Future<bool> loadHistoryMessageList({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    return await model?.loadData(
          count: count,
          getType: getType,
          lastMsgID: lastMsgID,
          lastMsgSeq: lastMsgSeq,
        ) ??
        false;
  }

  /// clear the current conversation;
  /// 销毁
  @Deprecated("No need to dispose after tim_ui_kit 0.1.4")
  dispose() {}

  /// clear the history of current conversation;
  /// 清除历史记录
  /// Please provide `convID`, if you use `TIMUIKitChatController` without specifying to a `TIMUIKitChat`.
  clearHistory([String? convID]) {
    if (convID != null) {
      return globalChatModel.setMessageList(convID, []);
    }
    return model?.clearHistory();
  }

  /// refresh the history message list manually;
  /// 手动刷新会话历史消息列表
  /// Please provide `convType` and `convID`, if you use `TIMUIKitChatController` without specifying to a `TIMUIKitChat`.
  Future<bool> refreshCurrentHistoryList(
      [String? convID, ConvType? convType]) async {
    if (convID != null && convType != null) {
      return globalChatModel.refreshCurrentHistoryListForConversation(
          count: 50, convID: convID, convType: convType);
    } else if (model != null) {
      return model!.loadDataFromController();
    }
    return false;
  }

  /// update single message at UI model
  /// 更新单条消息
  /// Please provide `convID`, if you use `TIMUIKitChatController` without specifying to a `TIMUIKitChat`.
  Future<void> updateMessage(
      {

      /// The ID of the target conversation
      String? convID,

      /// The type of the target conversation
      ConvType? convType,

      /// message ID
      required String msgID}) async {
    if (convID != null && convType != null) {
      return globalChatModel.updateMessageFromController(
          msgID: msgID, conversationID: convID, conversationType: convType);
    } else if (model != null) {
      return model!.updateMessageFromController(msgID: msgID);
    }
    return;
  }

  /// Send message;
  /// 发送消息
  /// Please provide `convType` and `convID`, if you use `TIMUIKitChatController` without specifying to a `TIMUIKitChat`.
  Future<V2TimValueCallback<V2TimMessage>?>? sendMessage({
    required V2TimMessage? messageInfo,

    /// The type of the target conversation
    ConvType? convType,

    /// The ID of the target conversation
    String? convID,

    /// The method for updating the input field when message sending failed
    ValueChanged<String>? setInputField,

    /// Offline push info
    OfflinePushInfo? offlinePushInfo,
  }) {
    if (convID != null && convType != null) {
      return globalChatModel.sendMessageFromController(
          messageInfo: messageInfo,
          convType: convType,
          convID: convID,
          setInputField: setInputField,
          offlinePushInfo: offlinePushInfo);
    } else if (model != null) {
      return model!.sendMessageFromController(
          messageInfo: messageInfo, offlinePushInfo: offlinePushInfo);
    }
    return null;
  }

  /// Send forward message;
  /// 逐条转发
  /// This method needs use with TIMUIKitChat directly or model been initialized.
  sendForwardMessage({
    required List<V2TimConversation> conversationList,
  }) async {
    model?.sendForwardMessage(conversationList: conversationList);
  }

  /// Send merger message;
  /// 合并转发
  /// This method needs use with TIMUIKitChat directly or model been initialized.
  Future<V2TimValueCallback<V2TimMessage>?> sendMergerMessage({
    required List<V2TimConversation> conversationList,
    required String title,
    required List<String> abstractList,
    required BuildContext context,
  }) async {
    return model?.sendMergerMessage(
        conversationList: conversationList,
        title: title,
        abstractList: abstractList,
        context: context);
  }

  /// Set local custom data; returns the bool shows if succeed
  /// 为本地消息配置额外String字段
  /// Please provide `convID`, if you use `TIMUIKitChatController` without specifying to a `TIMUIKitChat`.
  Future<bool> setLocalCustomData(String msgID, String localCustomData,
      [String? convID]) async {
    final String? conversationID = convID ?? model?.conversationID;
    if (conversationID == null) {
      return false;
    }
    return globalChatModel.setLocalCustomData(
        msgID, localCustomData, conversationID);
  }

  /// Set local custom int; returns the bool shows if succeed
  /// 为本地消息配置额外int字段
  /// Please provide `convID`, if you use `TIMUIKitChatController` without specifying to a `TIMUIKitChat`.
  Future<bool> setLocalCustomInt(String msgID, int localCustomInt,
      [String? convID]) async {
    final String? conversationID = convID ?? model?.conversationID;
    if (conversationID == null) {
      return false;
    }
    return globalChatModel.setLocalCustomInt(
        msgID, localCustomInt, conversationID);
  }

  /// Get current conversation, returns UserID or GroupID if in the chat page, returns "" if not.
  /// 获取当前会话ID，如果在Chat页面，返回UserID or GroupID， 反之返回""
  String getCurrentConversation() {
    return globalChatModel.currentSelectedConv;
  }
}
