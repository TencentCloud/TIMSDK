/// V2TimApplicationProcessed
///
/// {@category Models}
///
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

class V2TimApplicationProcessed {
  late String groupID;
  late V2TimGroupMemberInfo? opUser;
  late bool isAgreeJoin;
  late String? opReason;

  V2TimApplicationProcessed({
    required this.groupID,
    this.opUser,
    required this.isAgreeJoin,
    this.opReason,
  });

  V2TimApplicationProcessed.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    opUser = opUser == null
        ? null
        : V2TimGroupMemberInfo.fromJson(json['opUser']);
    isAgreeJoin = json['isAgreeJoin'];
    opReason = json['opReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['opUser'] = opUser!.toJson();
    data['isAgreeJoin'] = isAgreeJoin;
    data['opReason'] = opReason;
    return data;
  }
}
// {
//     "groupID": "",
//     "opUser": {},
//     "isAgreeJoin": true,
//     "opReason": ""
// }
