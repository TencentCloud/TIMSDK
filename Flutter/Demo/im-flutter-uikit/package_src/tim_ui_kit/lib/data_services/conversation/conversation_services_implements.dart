import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';

class ConversationServicesImpl extends ConversationService {
  @override
  Future<V2TimConversationResult?> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getConversationList(nextSeq: nextSeq, count: 100);
    return result.data;
  }

  @override
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .pinConversation(conversationID: conversationID, isPinned: isPinned);
  }

  @override
  Future<V2TimCallback> deleteConversation({
    required String conversationID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(conversationID: conversationID);
  }

  @override
  Future<void> setConversationListener({
    required V2TimConversationListener listener,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationListener(listener: listener);
  }

  @override
  Future<V2TimConversation?> getConversation({
    required String conversationID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    if (res.code == 0) return res.data;
  }
}
