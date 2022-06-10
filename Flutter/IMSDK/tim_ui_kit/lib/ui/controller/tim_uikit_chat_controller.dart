// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

import '../../tim_ui_kit.dart';

class TIMUIKitChatController {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  Future<bool> loadHistoryMessageList({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) {
    return model.loadData(
      count: count,
      getType: getType,
      userID: userID,
      groupID: groupID,
      lastMsgID: lastMsgID,
      lastMsgSeq: lastMsgSeq,
    );
  }

  /// set message listener;
  /// 添加消息监听器
  setMessageListener({V2TimAdvancedMsgListener? listener}) {
    return model.initAdvanceListener(listener: listener);
  }

  /// remove message listener;
  /// 移除监听器
  removeMessageListener() {
    return model.removeAdvanceListener();
  }

  /// clear the current conversation;
  /// 销毁
  dispose() {
    model.clear();
  }

  /// clear the history of current conversation;
  /// 清除历史记录
  clearHistory() {
    model.clearHistory();
  }

  /// refresh the history message list manually;
  /// 手动刷新会话历史消息列表
  refreshCurrentHistoryList(
      {

      /// if `convType` is missing, it will user current conversation on screen as default;
      /// 当不传convType时，默认使用当前页面视图的conversation
      ConvType? convType,

      /// `receiverID` is required only if `convType` is `ConvType.c2c`, it means the receiver user id of c2c conversation;
      /// 当convType为ConvType.c2c时，必传receiverID：单聊对方的ID
      String? receiverID,

      /// `groupID` is required only if `convType` is `ConvType.group`;
      /// 当convType为ConvType.group时，必传groupID：群聊ID
      String? groupID}) {
    return model.loadDataFromController(
        receiverID: receiverID, groupID: groupID, convType: convType);
  }

  /// update single message at UI model
  /// 更新单条消息
  Future<void> updateMessage(
      {

      /// message ID
      required String msgID,

      /// if `convType` is missing, it will user current conversation on screen as default;
      /// 当不传convType时，默认使用当前页面视图的conversation
      ConvType? convType,

      /// `receiverID` is required only if `convType` is `ConvType.c2c`, it means the receiver user id of c2c conversation;
      /// 当convType为ConvType.c2c时，必传receiverID：单聊对方的ID
      String? receiverID,

      /// `groupID` is required only if `convType` is `ConvType.group`;
      /// 当convType为ConvType.group时，必传groupID：群聊ID
      String? groupID}) async {
    return await model.updateMessageFromController(
        msgID: msgID,
        receiverID: receiverID,
        groupID: groupID,
        convType: convType);
  }

  /// Send message;
  /// 发送消息
  Future<V2TimValueCallback<V2TimMessage>?>? sendMessage(
      {required V2TimMessage? messageInfo,

      /// `receiverID` is required only if `convType` is `ConvType.c2c`, it means the receiver user id of c2c conversation;
      /// 当convType为ConvType.c2c时，必传receiverID：单聊对方的ID
      String? receiverID,

      /// `groupID` is required only if `convType` is `ConvType.group`;
      /// 当convType为ConvType.group时，必传groupID：群聊ID
      String? groupID,
      required ConvType convType}) {
    final convID = convType == ConvType.c2c ? receiverID : groupID;
    if (convID != null && convID.isNotEmpty) {
      return model.sendMessageFromController(
          messageInfo: messageInfo, convID: convID, convType: convType);
    } else {
      print("ID is empty");
      return null;
    }
  }

  /// Send forward message;
  /// 逐条转发
  sendForwardMessage({
    required List<V2TimConversation> conversationList,
  }) async {
    model.sendForwardMessage(conversationList: conversationList);
  }

  /// Send merger message;
  /// 合并转发
  Future<V2TimValueCallback<V2TimMessage>?> sendMergerMessage({
    required List<V2TimConversation> conversationList,
    required String title,
    required List<String> abstractList,
    required BuildContext context,
  }) async {
    return model.sendMergerMessage(
        conversationList: conversationList,
        title: title,
        abstractList: abstractList,
        context: context);
  }
}
