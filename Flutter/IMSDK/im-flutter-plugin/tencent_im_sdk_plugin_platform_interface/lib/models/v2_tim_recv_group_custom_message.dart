import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_info.dart';

/// V2TimRecvGroupCustomMessage
///
/// {@category Models}
///
class V2TimRecvGroupCustomMessage {
  late String msgID;
  late V2TimUserInfo sender;
  late String groupID;
  late String? customData;

  V2TimRecvGroupCustomMessage({
    required this.msgID,
    required this.sender,
    required this.groupID,
    this.customData,
  });

  V2TimRecvGroupCustomMessage.fromJson(Map<String, dynamic> json) {
    msgID = json['msgID'];
    sender = V2TimUserInfo.fromJson(json['sender']);
    groupID = json['groupID'];
    customData = json['customData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msgID'] = msgID;
    data['sender'] = sender.toJson();
    data['groupID'] = groupID;
    data['customData'] = customData;
    return data;
  }
}
// {
//   "msgID":",",
//   "sender":{},
//   "groupID":"",
//   "customData":""
// }
