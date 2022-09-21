import 'package:tencent_im_base/tencent_im_base.dart';

abstract class ConversationService {
  Future<V2TimConversationResult?> getConversationList({
    required String nextSeq,
    required int count,
  });

  Future<V2TimConversation?> getConversation({
    required String conversationID,
  });

  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  });

  Future<V2TimCallback> deleteConversation({
    required String conversationID,
  });

  Future<void> addConversationListener({
    required V2TimConversationListener listener,
  });

  Future<V2TimCallback> setConversationDraft(
      {required String conversationID, String? draftText});

  Future<void> removeConversationListener(
      {V2TimConversationListener? listener});

  Future<int> getTotalUnreadCount();

  Future<V2TimConversation?> getConversationListByConversationId(
      {required String convID});
}
