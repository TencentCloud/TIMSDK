// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class GroupMemberRole {
  external static dynamic TYPES; // 这个是用作枚举的
}

class GroupMemberRoleWeb {
  static String GRP_MBR_ROLE_ADMIN =
      jsToMap(GroupMemberRole.TYPES)['GRP_MBR_ROLE_ADMIN']; // 管理员
  static String GRP_MBR_ROLE_MEMBER =
      jsToMap(GroupMemberRole.TYPES)['GRP_MBR_ROLE_MEMBER']; // 成员
  static String GRP_MBR_ROLE_OWNER =
      jsToMap(GroupMemberRole.TYPES)['GRP_MBR_ROLE_OWNER']; // 群主

  static int convertGroupMemberRole(String role) {
    if (role == GRP_MBR_ROLE_ADMIN) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
    }

    if (role == GRP_MBR_ROLE_MEMBER) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
    }

    if (role == GRP_MBR_ROLE_OWNER) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER;
    }

    return GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
  }

  static String convertGroupMemberRoleToWeb(int role) {
    if (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
      return GRP_MBR_ROLE_ADMIN;
    }

    if (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER) {
      return GRP_MBR_ROLE_MEMBER;
    }

    if (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
      return GRP_MBR_ROLE_OWNER;
    }

    return '';
  }
}
