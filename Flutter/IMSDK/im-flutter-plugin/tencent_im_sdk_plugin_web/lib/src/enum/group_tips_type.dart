// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class GroupTipsEnum {
  external static dynamic TYPES; // 这个是用作枚举的
}

class GroupTips {
  static int GRP_TIP_MBR_JOIN =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_MBR_JOIN'];
  static int GRP_TIP_MBR_QUIT =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_MBR_QUIT'];
  static int GRP_TIP_MBR_KICKED_OUT =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_MBR_KICKED_OUT'];
  static int GRP_TIP_MBR_SET_ADMIN =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_MBR_SET_ADMIN'];
  static int GRP_TIP_MBR_CANCELED_ADMIN =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_MBR_CANCELED_ADMIN'];
  static int GRP_TIP_GRP_PROFILE_UPDATED =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_GRP_PROFILE_UPDATED'];
  static int GRP_TIP_MBR_PROFILE_UPDATED =
      jsToMap(GroupTipsEnum.TYPES)['GRP_TIP_MBR_PROFILE_UPDATED'];
}
