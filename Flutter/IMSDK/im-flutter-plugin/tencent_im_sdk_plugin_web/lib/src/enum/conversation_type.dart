import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
// 获取会话类型的type，web中此type为String，dart为int
class ConversationEnum {
  external static dynamic TYPES; // 这个是用作枚举的
}

class ConversationTypeWeb {
  //C2c会话
  static String CONV_C2C =
      checkEmptyEnum(() => jsToMap(ConversationEnum.TYPES)['CONV_C2C'], "C2C");
  // 群组会话
  static String CONV_GROUP = checkEmptyEnum(
      () => jsToMap(ConversationEnum.TYPES)['CONV_GROUP'], "GROUP");

  //系统会话。该会话只能接收来自系统的通知消息，不能发送消息。
  static String CONV_SYSTEM = checkEmptyEnum(
      () => jsToMap(ConversationEnum.TYPES)['CONV_SYSTEM'], "@TIM#SYSTEM");

  static int convertConverstationtType(String type) {
    if (type == CONV_C2C) {
      return ConversationType.V2TIM_C2C;
    }
    if (type == CONV_GROUP) {
      return ConversationType.V2TIM_GROUP;
    }

    return ConversationType.CONVERSATION_TYPE_INVALID;
  }
}
