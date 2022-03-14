import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_member_role_enum.dart';

class EnumUtils {
  static int convertGroupMemberRoleTypeEnum(GroupMemberRoleTypeEnum role) {
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
    }
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
    }
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER;
    }
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_UNDEFINED) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
    }
    return GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
  }
}
