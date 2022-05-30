// ignore_for_file: unused_import

import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';

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
