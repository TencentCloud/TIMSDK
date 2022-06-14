import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

/// V2TimMemberLeave
///
/// {@category Models}
///
class V2TimMemberLeave {
  late String groupID;
  late V2TimGroupMemberInfo member;

  V2TimMemberLeave({
    required this.groupID,
    required this.member,
  });

  V2TimMemberLeave.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    member = V2TimGroupMemberInfo.fromJson(json['member']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['member'] = member.toJson();
    return data;
  }
}

// {
//  "groupID":"",
//   "member":{}
// }
