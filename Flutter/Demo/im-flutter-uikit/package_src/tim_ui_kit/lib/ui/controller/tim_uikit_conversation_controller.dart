import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';

class TIMUIKitConversationController {
  TUIConversationViewModel model = TUIConversationViewModel();

  /// 获取选中的会话
  V2TimConversation? get selectedConversation {
    return model.selectedConversation;
  }

  /// 获取会话列表
  List<V2TimConversation?> get conversationList {
    return model.conversationList;
  }

  /// 设置会话列表
  set conversationList(List<V2TimConversation?> conversationList) {
    model.conversationList = conversationList;
  }

  /// 加载会话列表数据
  loadData({int count = 100}) {
    model.loadData(count: count);
  }

  /// 重新加载会话列表数据
  reloadData({int count = 100}) {
    model.clear();
    model.loadData(count: count);
  }

  /// 设置会话置顶
  pinConversation({required String conversationID, required bool isPinned}) {
    return model.pinConversation(
        conversationID: conversationID, isPinned: isPinned);
  }

  /// 设置会话草稿
  setConversationDraft({required String conversationID, String? draftText}) {
    return model.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  /// 清除指定会话消息
  clearHistoryMessage({required V2TimConversation conversation}) {
    final convType = conversation.type;
    final convID = convType == 1 ? conversation.userID : conversation.groupID;
    if (convType != null && convID != null) {
      model.clearHistoryMessage(convID: convID, convType: convType);
    }
  }

  /// 删除会话
  deleteConversation({required String conversationID}) {
    model.deleteConversation(conversationID: conversationID);
  }

  /// 添加会话监听器
  setConversationListener({V2TimConversationListener? listener}) {
    model.setConversationListener(listener: listener);
  }

  /// 移除会话监听器
  removeConversationListener() {
    model.removeConversationListener();
  }

  /// 销毁
  dispose() {
    model.removeConversationListener();
    model.clear();
  }
}
