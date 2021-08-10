import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';

/// V2TimMemberInvited
///
/// {@category Models}
///
class V2TimMemberInvited {
  late String groupID;
  late V2TimGroupMemberInfo opUser;
  List<V2TimGroupMemberInfo>? memberList = List.empty(growable: true);

  V2TimMemberInvited({
    required this.groupID,
    required this.opUser,
    this.memberList,
  });

  V2TimMemberInvited.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    opUser = new V2TimGroupMemberInfo.fromJson(json['opUser']);
    if (json['memberList'] != null) {
      memberList = List.empty(growable: true);
      json['memberList'].forEach((v) {
        memberList!.add(new V2TimGroupMemberInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['opUser'] = this.opUser.toJson();
    if (this.memberList != null) {
      data['memberList'] = this.memberList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
// {
//   "groupID":"",
//   "opUser":{},
//   "memberList":[{}]
// }
