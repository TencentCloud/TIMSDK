import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

import '../../tim_ui_kit.dart';

class TIMUIKitChatController {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  /// 添加消息监听器
  setMessageListener({V2TimAdvancedMsgListener? listener}) {
    return model.initAdvanceListener(listener: listener);
  }

  /// 移除监听器
  removeMessageListener() {
    return model.removeAdvanceListener();
  }

  /// 销毁
  dispose() {
    model.clear();
  }

  /// 清除历史记录
  clearHistory() {
    model.clearHistory();
  }

  /// 发送消息
  Future<V2TimValueCallback<V2TimMessage>?>? sendMessage(
      {required V2TimMessage? messageInfo,

      /// 当convType为ConvType.c2c时，必传receiverID：单聊对方的ID
      String? receiverID,

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

  /// 逐条转发
  sendForwardMessage({
    required List<V2TimConversation> conversationList,
  }) async {
    model.sendForwardMessage(conversationList: conversationList);
  }

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
