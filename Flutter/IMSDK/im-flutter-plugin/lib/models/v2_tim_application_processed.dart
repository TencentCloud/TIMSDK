/// V2TimApplicationProcessed
///
/// {@category Models}
///
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';

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
        : new V2TimGroupMemberInfo.fromJson(json['opUser']);
    isAgreeJoin = json['isAgreeJoin'];
    opReason = json['opReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['opUser'] = this.opUser!.toJson();
    data['isAgreeJoin'] = this.isAgreeJoin;
    data['opReason'] = this.opReason;
    return data;
  }
}
// {
//     "groupID": "",
//     "opUser": {},
//     "isAgreeJoin": true,
//     "opReason": ""
// }
