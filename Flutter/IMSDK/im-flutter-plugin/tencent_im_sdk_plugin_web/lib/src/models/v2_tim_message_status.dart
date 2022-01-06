import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_status.dart';

class MessageStatusWeb {
  static int convertMessageStatus(dynamic message) {
    final String status = message["status"];
    final bool isRevoked = message["isRevoked"];
    final bool isDeleted = message["isDeleted"];
    if (status == 'success') {
      return MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC;
    }

    if (status == 'fail') {
      return MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL;
    }

    if (isDeleted) {
      return MessageStatus.V2TIM_MSG_STATUS_HAS_DELETED;
    }

    if (isRevoked) {
      return MessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED;
    }

    return 0;
  }
}
