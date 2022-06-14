import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

/// V2TimGroupDismissed
///
/// {@category Models}
///
class V2TimGroupDismissed {
  late String groupID;
  late V2TimGroupMemberInfo opUser;

  V2TimGroupDismissed({
    required this.groupID,
    required this.opUser,
  });

  V2TimGroupDismissed.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    opUser = V2TimGroupMemberInfo.fromJson(json['opUser']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['opUser'] = opUser.toJson();
    return data;
  }
}
// {
//   "groupID":"",
//   "opUser":{}
// }
