// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class GroupAddOptEnum {
  external static dynamic TYPES; // 这个是用作枚举的
}

class GroupAddOptWeb {
  static String JOIN_OPTIONS_FREE_ACCESS =
      jsToMap(GroupAddOptEnum.TYPES)["JOIN_OPTIONS_FREE_ACCESS"];
  static String JOIN_OPTIONS_NEED_PERMISSION =
      jsToMap(GroupAddOptEnum.TYPES)["JOIN_OPTIONS_NEED_PERMISSION"];
  static String JOIN_OPTIONS_DISABLE_APPLY =
      jsToMap(GroupAddOptEnum.TYPES)["JOIN_OPTIONS_DISABLE_APPLY"];

  static int? convertGroupAddOpt(String opt) {
    if (opt == JOIN_OPTIONS_FREE_ACCESS) {
      return GroupAddOptType.V2TIM_GROUP_ADD_ANY;
    }

    if (opt == JOIN_OPTIONS_NEED_PERMISSION) {
      return GroupAddOptType.V2TIM_GROUP_ADD_AUTH;
    }

    if (opt == JOIN_OPTIONS_DISABLE_APPLY) {
      return GroupAddOptType.V2TIM_GROUP_ADD_FORBID;
    }
    return null;
  }

  static String? convertGroupAddOptToWeb(int? opt) {
    if (opt == GroupAddOptType.V2TIM_GROUP_ADD_ANY) {
      return JOIN_OPTIONS_FREE_ACCESS;
    }

    if (opt == GroupAddOptType.V2TIM_GROUP_ADD_AUTH) {
      return JOIN_OPTIONS_NEED_PERMISSION;
    }

    if (opt == GroupAddOptType.V2TIM_GROUP_ADD_FORBID) {
      return JOIN_OPTIONS_DISABLE_APPLY;
    }
    return null;
  }
}
