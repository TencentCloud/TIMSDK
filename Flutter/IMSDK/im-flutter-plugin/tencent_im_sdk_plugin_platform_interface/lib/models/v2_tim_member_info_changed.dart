import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_change_info.dart';

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
            .add(V2TimGroupMemberChangeInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    if (groupMemberChangeInfoList != null) {
      data['groupMemberChangeInfoList'] =
          groupMemberChangeInfoList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "groupID":"",
//   "groupMemberChangeInfoList":[{}]
// }
