// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class GroupRecvMsgEnum {
  external static dynamic TYPES; // 这个是用作枚举的
}

class GroupRecvMsgOpt {
  static String MSG_REMIND_ACPT_AND_NOTE =
      jsToMap(GroupRecvMsgEnum.TYPES)["MSG_REMIND_ACPT_AND_NOTE"];
  static String MSG_REMIND_ACPT_NOT_NOTE =
      jsToMap(GroupRecvMsgEnum.TYPES)["MSG_REMIND_ACPT_NOT_NOTE"];
  static String MSG_REMIND_DISCARD =
      jsToMap(GroupRecvMsgEnum.TYPES)["MSG_REMIND_DISCARD"];

  static int? convertMsgRecvOpt(String opt) {
    if (opt == MSG_REMIND_ACPT_AND_NOTE) {
      return 0;
    }

    if (opt == MSG_REMIND_DISCARD) {
      return 1;
    }

    if (opt == MSG_REMIND_ACPT_NOT_NOTE) {
      return 2;
    }
    return null;
  }

  static String? convertMsgRecvOptToWeb(int opt) {
    if (opt == 0) {
      return MSG_REMIND_ACPT_AND_NOTE;
    }

    if (opt == 1) {
      return MSG_REMIND_DISCARD;
    }

    if (opt == 2) {
      return MSG_REMIND_ACPT_NOT_NOTE;
    }
    return null;
  }
}
