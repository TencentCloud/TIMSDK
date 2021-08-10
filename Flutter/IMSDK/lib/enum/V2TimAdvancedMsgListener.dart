// void 	onRecvNewMessage (V2TIMMessage msg)

// void 	onRecvC2CReadReceipt (List< V2TIMMessageReceipt > receiptList)

// void 	onRecvMessageRevoked (String msgID)
//
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';

import 'callbacks.dart';

class V2TimAdvancedMsgListener {
  OnRecvNewMessageCallback onRecvNewMessage = (V2TimMessage message) {};
  OnSendMessageProgressCallback onSendMessageProgress =
      (V2TimMessage message, int progress) {};
  OnRecvC2CReadReceiptCallback onRecvC2CReadReceipt =
      (List<V2TimMessageReceipt> receiptList) {};
  OnRecvMessageRevokedCallback onRecvMessageRevoked = (String msgID) {};

  V2TimAdvancedMsgListener({
    OnRecvC2CReadReceiptCallback? onRecvC2CReadReceipt,
    OnRecvMessageRevokedCallback? onRecvMessageRevoked,
    OnRecvNewMessageCallback? onRecvNewMessage,
    OnSendMessageProgressCallback? onSendMessageProgress,
  }) {
    if (onRecvC2CReadReceipt != null) {
      this.onRecvC2CReadReceipt = onRecvC2CReadReceipt;
    }
    if (onRecvMessageRevoked != null) {
      this.onRecvMessageRevoked = onRecvMessageRevoked;
    }
    if (onRecvNewMessage != null) {
      this.onRecvNewMessage = onRecvNewMessage;
    }
    if (onSendMessageProgress != null) {
      this.onSendMessageProgress = onSendMessageProgress;
    }
  }
}
