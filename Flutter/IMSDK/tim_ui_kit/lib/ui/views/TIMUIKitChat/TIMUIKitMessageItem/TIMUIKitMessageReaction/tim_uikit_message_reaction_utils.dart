import 'dart:convert';

import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';

class MessageReactionUtils {
  static final TUISelfInfoViewModel selfInfoModel =
      serviceLocator<TUISelfInfoViewModel>();
  static final MessageService _messageService =
      serviceLocator<MessageService>();

  static CloudCustomData getCloudCustomData(V2TimMessage message) {
    CloudCustomData messageCloudCustomData;
    try {
      messageCloudCustomData =
          CloudCustomData.fromJson(json.decode(message.cloudCustomData!));
    } catch (e) {
      messageCloudCustomData = CloudCustomData();
    }

    return messageCloudCustomData;
  }

  static Map<String, dynamic> getMessageReaction(V2TimMessage message) {
    return getCloudCustomData(message).messageReaction ?? {};
  }

  static Future<V2TimValueCallback<V2TimMessageChangeInfo>> clickOnSticker(
      V2TimMessage message, int sticker) async {
    final CloudCustomData messageCloudCustomData = getCloudCustomData(message);
    final Map<String, dynamic> messageReaction =
        messageCloudCustomData.messageReaction ?? {};
    List targetList = messageReaction["$sticker"] ?? [];
    if (targetList.contains(selfInfoModel.loginInfo!.userID!)) {
      targetList.remove(selfInfoModel.loginInfo!.userID!);
    } else {
      targetList = [selfInfoModel.loginInfo!.userID!, ...targetList];
    }
    messageReaction["$sticker"] = targetList;

    message.cloudCustomData = json.encode(messageCloudCustomData.toMap());
    return await _messageService.modifyMessage(message: message);
  }
}
