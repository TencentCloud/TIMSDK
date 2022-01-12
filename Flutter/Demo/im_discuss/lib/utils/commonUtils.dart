import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';

class CommonUtils {
  static bool isReceivingAndNotifingMessage(int recvOpt) {
    return ReceiveMsgOptEnum.values[recvOpt] ==
        ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE;
  }
}
