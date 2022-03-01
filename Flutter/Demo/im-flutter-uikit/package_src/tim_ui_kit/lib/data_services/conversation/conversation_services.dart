import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';

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

  Future<void> setConversationListener({
    required V2TimConversationListener listener,
  });
}
