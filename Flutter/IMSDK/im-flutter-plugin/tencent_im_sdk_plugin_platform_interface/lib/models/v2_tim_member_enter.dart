import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

/// V2TimMemberEnter
///
/// {@category Models}
///
class V2TimMemberEnter {
  late String groupID;
  late List<V2TimGroupMemberInfo?>? memberList = List.empty(growable: true);

  V2TimMemberEnter({required this.groupID, this.memberList});

  V2TimMemberEnter.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    if (json['memberList'] != null) {
      memberList = List.empty(growable: true);
      json['memberList'].forEach((v) {
        memberList!.add(V2TimGroupMemberInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    if (memberList != null) {
      data['memberList'] = memberList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "groupID":"",
//   "memberList":[{}]
// }
