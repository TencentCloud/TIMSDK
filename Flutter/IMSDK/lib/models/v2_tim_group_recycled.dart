import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';

/// V2TimGroupRecycled
///
/// {@category Models}
///
class V2TimGroupRecycled {
  late String groupID;
  late V2TimGroupMemberInfo opUser;

  V2TimGroupRecycled({
    required this.groupID,
    required this.opUser,
  });

  V2TimGroupRecycled.fromJson(Map<String, dynamic> json) {
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
