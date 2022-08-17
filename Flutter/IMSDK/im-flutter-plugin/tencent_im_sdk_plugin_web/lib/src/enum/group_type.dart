// ignore_for_file: non_constant_identifier_names, missing_js_lib_annotation

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class GroupTypeEnum {
  external static dynamic TYPES; // 这个是用作枚举的
}

class GroupTypeWeb {
  static String GRP_WORK = jsToMap(GroupTypeEnum.TYPES)["GRP_WORK"]; // wrok 群
  static String GRP_PUBLIC =
      jsToMap(GroupTypeEnum.TYPES)["GRP_PUBLIC"]; // public
  static String GRP_AVCHATROOM =
      jsToMap(GroupTypeEnum.TYPES)["GRP_AVCHATROOM"]; // avchat room
  static String GRP_MEETING =
      jsToMap(GroupTypeEnum.TYPES)["GRP_MEETING"]; // chat room
  static String GRP_COMMUNITY = jsToMap(GroupTypeEnum.TYPES)["GRP_COMMUNITY"];

  static String? convertGroupType(String type) {
    if (type == GRP_WORK) {
      return GroupType.Work;
    }

    if (type == GRP_PUBLIC) {
      return GroupType.Public;
    }

    if (type == GRP_AVCHATROOM) {
      return GroupType.AVChatRoom;
    }

    if (type == GRP_MEETING) {
      return GroupType.Meeting;
    }

    if (type == GRP_COMMUNITY) {
      return GroupType.Community;
    }
    return null;
  }

  static String convertGroupTypeToWeb(String type) {
    if (type == GroupType.Work) {
      return GRP_WORK;
    }

    if (type == GroupType.Public) {
      return GRP_PUBLIC;
    }

    if (type == GroupType.AVChatRoom) {
      return GRP_AVCHATROOM;
    }

    if (type == GroupType.Meeting) {
      return GRP_MEETING;
    }

    if (type == GroupType.Community) {
      return GRP_COMMUNITY;
    }

    return '';
  }
}
