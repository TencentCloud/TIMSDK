import 'package:tencent_im_sdk_plugin_web/src/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

final groupMemberRoleMapping = {"Owner": 400, "Admin": 300, "Member": 200};

class SetGroupMemberRole {
  static Object formatParams(Map<String, dynamic> params) => mapToJSObj({
        'groupID': params['groupID'],
        'userID': params['userID'],
        'role': GroupMemberRoleWeb.convertGroupMemberRoleToWeb(params['role'])
      });
}
