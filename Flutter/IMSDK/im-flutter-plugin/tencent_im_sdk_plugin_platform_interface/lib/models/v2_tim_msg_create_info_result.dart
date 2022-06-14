import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';


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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (messageInfo != null) {
      data['memberInfoList'] = messageInfo!.toJson();
    }
    return data;
  }
}
// {
//   "nextSeq":0,
//   "memberInfoList":[{}]
// }
