import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';

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
    opUser = new V2TimGroupMemberInfo.fromJson(json['opUser']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['opUser'] = this.opUser.toJson();
    return data;
  }
}
// {
//   "groupID":"",
//   "opUser":{}
// }
