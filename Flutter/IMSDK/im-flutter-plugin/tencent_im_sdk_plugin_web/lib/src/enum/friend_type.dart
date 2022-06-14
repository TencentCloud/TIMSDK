// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
// 获取会话类型的type，web中此type为String，dart为int
class TIMTYPE {
  external static dynamic TYPES; // 这个是用作枚举的
}

class FriendTypeWeb {
  static String SNS_ADD_TYPE_SINGLE =
      jsToMap(TIMTYPE.TYPES)['SNS_ADD_TYPE_SINGLE'];
  static String SNS_ADD_TYPE_BOTH = jsToMap(TIMTYPE.TYPES)['SNS_ADD_TYPE_BOTH'];

  // 单双向校验好友有可能出现的情况
  static String SNS_TYPE_NO_RELATION =
      jsToMap(TIMTYPE.TYPES)['SNS_TYPE_NO_RELATION'];
  static String SNS_TYPE_A_WITH_B = jsToMap(TIMTYPE.TYPES)['SNS_TYPE_A_WITH_B'];
  static String SNS_TYPE_B_WITH_A = jsToMap(TIMTYPE.TYPES)['SNS_TYPE_B_WITH_A'];
  static String SNS_TYPE_BOTH_WAY = jsToMap(TIMTYPE.TYPES)['SNS_TYPE_BOTH_WAY'];

  static String SNS_APPLICATION_AGREE =
      jsToMap(TIMTYPE.TYPES)['SNS_APPLICATION_AGREE'];
  static String SNS_APPLICATION_AGREE_AND_ADD =
      jsToMap(TIMTYPE.TYPES)['SNS_APPLICATION_AGREE_AND_ADD'];

  // 好友申请列表
  static String SNS_APPLICATION_TYPE_BOTH =
      jsToMap(TIMTYPE.TYPES)['SNS_APPLICATION_TYPE_BOTH'];
  static String SNS_APPLICATION_SENT_TO_ME =
      jsToMap(TIMTYPE.TYPES)['SNS_APPLICATION_SENT_TO_ME'];
  static String SNS_APPLICATION_SENT_BY_ME =
      jsToMap(TIMTYPE.TYPES)['SNS_APPLICATION_SENT_BY_ME'];

  static const V2TIM_FRIEND_RELATION_TYPE_NONE = 0;
  static const V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST = 1;
  static const V2TIM_FRIEND_RELATION_TYPE_IN_OTHER_FRIEND_LIST = 2;
  static const V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY = 3;

  // 好友申请列表
  static const V2TIM_FRIEND_APPLICATION_COME_IN = 1; // 别人发给我的加好友请求
  static const V2TIM_FRIEND_APPLICATION_SEND_OUT = 2; // 我发给别人的加好友请求
  static const V2TIM_FRIEND_APPLICATION_BOTH = 3; // 别人发给我的和我发给别人的加好友请求。仅在拉取时有效。
  // 是否接受好友申请
  static const V2TIM_FRIEND_ACCEPT_AGREE = 0;
  static const V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD = 1;

  static String convertWebFriendType(int type) {
    if (FriendType.V2TIM_FRIEND_TYPE_SINGLE == type) {
      return jsToMap(TIMTYPE.TYPES)['SNS_ADD_TYPE_SINGLE'];
    }
    if (FriendType.V2TIM_FRIEND_TYPE_BOTH == type) {
      return jsToMap(TIMTYPE.TYPES)['SNS_ADD_TYPE_BOTH'];
    }
    return type.toString();
  }

  // 单双向校验好友 -> dart
  static int convertFromWebCheckFriendType(String type) {
    if (type == SNS_TYPE_NO_RELATION) {
      return V2TIM_FRIEND_RELATION_TYPE_NONE;
    }
    if (type == SNS_TYPE_A_WITH_B) {
      return V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST;
    }
    if (type == SNS_TYPE_B_WITH_A) {
      return V2TIM_FRIEND_RELATION_TYPE_IN_OTHER_FRIEND_LIST;
    }
    if (type == SNS_TYPE_BOTH_WAY) {
      return V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY;
    }
    return -1;
  }

  static int convertFromApplicationFriendType(String type) {
    if (type == SNS_APPLICATION_TYPE_BOTH) {
      return V2TIM_FRIEND_APPLICATION_BOTH;
    }
    if (type == SNS_APPLICATION_SENT_TO_ME) {
      return V2TIM_FRIEND_APPLICATION_COME_IN;
    }
    if (type == SNS_APPLICATION_SENT_BY_ME) {
      return V2TIM_FRIEND_APPLICATION_SEND_OUT;
    }
    return -1;
  }

  static String convertToApplicationFriendType(int type) {
    if (type == V2TIM_FRIEND_APPLICATION_BOTH) {
      return SNS_APPLICATION_TYPE_BOTH;
    }
    if (type == V2TIM_FRIEND_APPLICATION_COME_IN) {
      return SNS_APPLICATION_SENT_TO_ME;
    }
    if (type == V2TIM_FRIEND_APPLICATION_SEND_OUT) {
      return SNS_APPLICATION_SENT_BY_ME;
    }
    return "undefind enum";
  }

  static String convertToAcceptFriendType(int type) {
    if (type == V2TIM_FRIEND_ACCEPT_AGREE) {
      return SNS_APPLICATION_AGREE;
    }
    if (type == V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD) {
      return SNS_APPLICATION_AGREE_AND_ADD;
    }
    return SNS_APPLICATION_AGREE_AND_ADD;
  }
}
