import 'package:tencent_im_sdk_plugin_web/src/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/message_type.dart';

import '../utils.dart';

class V2TimMessageManagerMockData {
  static Map<String, dynamic> textMessageResultList =
      CommonUtils.buildParam([Message.textMessage]);
}

// 这个要和JS的字段对齐
class Message {
  static Map<String, dynamic> textMessage = {
    "conversationType": ConversationTypeWeb.CONV_C2C,
    "type": MsgType.MSG_TEXT,
    "ID": "messageID_666",
    "from": "your heart",
    "nick": "星星与辰辰",
    "avatar": "https://profile.csdnimg.cn/D/9/1/2_weixin_44956861",
    "payload": {"text": "星辰通信中心最帅的男人！"}
  };
}
