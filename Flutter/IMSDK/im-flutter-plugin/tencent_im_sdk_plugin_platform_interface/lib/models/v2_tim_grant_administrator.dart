import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

/// V2TimGrantAdministrator
///
/// {@category Models}
///
class V2TimGrantAdministrator {
  late String groupID;
  V2TimGroupMemberInfo? opUser;
  List<V2TimGroupMemberInfo>? memberList = List.empty(growable: true);

  V2TimGrantAdministrator({
    required this.groupID,
    this.opUser,
    this.memberList,
  });

  V2TimGrantAdministrator.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    opUser = json['opUser'] != null
        ? V2TimGroupMemberInfo.fromJson(json['opUser'])
        : null;
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
    if (opUser != null) {
      data['opUser'] = opUser!.toJson();
    }
    if (memberList != null) {
      data['memberList'] = memberList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
// {
//   "groupID":"",
//   "opUser":{},
//   "memberList":[{}]
// }
