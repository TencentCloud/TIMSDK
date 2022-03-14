import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_member_role_enum.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/utils.dart';

class V2TimGroupMember {
  late String userID;
  late GroupMemberRoleTypeEnum role;
  V2TimGroupMember({required this.userID, required this.role});
  fromJson(String userID, GroupMemberRoleTypeEnum role) {
    this.userID = userID;
    this.role = role;
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "userID": userID,
      "role": EnumUtils.convertGroupMemberRoleTypeEnum(role)
    };
  }
}
