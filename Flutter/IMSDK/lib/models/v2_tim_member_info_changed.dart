import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_change_info.dart';

/// V2TimMemberInfoChanged
///
/// {@category Models}
///
class V2TimMemberInfoChanged {
  late String groupID;
  late List<V2TimGroupMemberChangeInfo?>? groupMemberChangeInfoList =
      List.empty(growable: true);

  V2TimMemberInfoChanged({
    required this.groupID,
    this.groupMemberChangeInfoList,
  });

  V2TimMemberInfoChanged.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    if (json['groupMemberChangeInfoList'] != null) {
      groupMemberChangeInfoList = List.empty(growable: true);
      json['groupMemberChangeInfoList'].forEach((v) {
        groupMemberChangeInfoList!
            .add(new V2TimGroupMemberChangeInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    if (this.groupMemberChangeInfoList != null) {
      data['groupMemberChangeInfoList'] =
          this.groupMemberChangeInfoList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "groupID":"",
//   "groupMemberChangeInfoList":[{}]
// }
