import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';

class TIMUIKitConversationController {
  late TUIConversationViewModel model;

  /// Get the selected conversation currently
  V2TimConversation? get selectedConversation {
    return model.selectedConversation;
  }

  /// Get the conversation list
  List<V2TimConversation?> get conversationList {
    return model.conversationList;
  }

  /// Set the conversation list
  set conversationList(List<V2TimConversation?> conversationList) {
    model.conversationList = conversationList;
  }

  /// Load the conversation list to UI
  loadData({int count = 20}) {
    model.loadData(count: count);
  }

  /// Reload the conversation list to UI
  reloadData({int count = 100}) {
    model.refresh(count: count);
  }

  /// Pin one conversation to the top
  Future<V2TimCallback> pinConversation(
      {required String conversationID, required bool isPinned}) {
    return model.pinConversation(
        conversationID: conversationID, isPinned: isPinned);
  }

  /// Set the draft for a conversation
  Future<V2TimCallback> setConversationDraft(
      {required String conversationID, String? draftText}) {
    return model.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  /// Clear the historical message in a specific conversation
  Future<V2TimCallback?>? clearHistoryMessage(
      {required V2TimConversation conversation}) {
    final convType = conversation.type;
    final convID = convType == 1 ? conversation.userID : conversation.groupID;
    if (convType != null && convID != null) {
      return model.clearHistoryMessage(convID: convID, convType: convType);
    }
    return null;
  }

  /// Delete a conversation
  Future<V2TimCallback?> deleteConversation({required String conversationID}) {
    return model.deleteConversation(conversationID: conversationID);
  }

  /// Clear the conversation list from UI
  dispose() {
    model.clearData();
  }
}
