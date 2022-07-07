import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class ConversationServicesImpl extends ConversationService {
  final CoreServicesImpl _coreService = serviceLocator<CoreServicesImpl>();

  @override
  Future<V2TimConversationResult?> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getConversationList(nextSeq: nextSeq, count: count);
    if (result.code == 0) {
      return result.data;
    } else {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
      return null;
    }
  }

  @override
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .pinConversation(conversationID: conversationID, isPinned: isPinned);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> deleteConversation({
    required String conversationID,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(conversationID: conversationID);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<void> setConversationListener({
    required V2TimConversationListener listener,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .addConversationListener(listener: listener);
  }

  @override
  Future<V2TimConversation?> getConversation({
    required String conversationID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    if (res.code == 0) {
      return res.data;
    } else {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: res.desc,
          errorCode: res.code));
    }
    return null;
  }

  @override
  Future<V2TimCallback> setConversationDraft(
      {required String conversationID, String? draftText}) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(
            conversationID: conversationID, draftText: draftText);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<void> removeConversationListener(
      {V2TimConversationListener? listener}) {
    return TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .removeConversationListener(listener: listener);
  }
}
