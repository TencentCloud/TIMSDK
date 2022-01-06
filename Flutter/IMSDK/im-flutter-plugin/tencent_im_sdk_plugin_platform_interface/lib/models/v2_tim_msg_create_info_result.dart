import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';

import 'v2_tim_group_member_full_info.dart';

/// V2TimGroupMemberInfoResult
///
/// {@category Models}
///

class V2TimMsgCreateInfoResult {
  late String? id;
  late V2TimMessage? messageInfo;

  V2TimMsgCreateInfoResult({
    this.id,
    this.messageInfo,
  });

  V2TimMsgCreateInfoResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageInfo = V2TimMessage.fromJson(json['messageInfo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.messageInfo != null) {
      data['memberInfoList'] = messageInfo!.toJson();
    }
    return data;
  }
}
// {
//   "nextSeq":0,
//   "memberInfoList":[{}]
// }
