import 'package:tim_ui_kit/tim_ui_kit.dart';

class TIMUIKitChatUtils {
  static String? getMessageIDWithinIndex(
      List<V2TimMessage?> messageList, int index) {
    if (messageList[index]!.elemType == 11) {
      return getMessageIDWithinIndex(messageList, index - 1);
    }
    return messageList[index]!.msgID;
  }
}
