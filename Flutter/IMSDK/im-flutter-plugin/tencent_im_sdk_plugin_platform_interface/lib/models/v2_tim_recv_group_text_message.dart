import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_info.dart';

/// V2TimRecvGroupTextMessage
///
/// {@category Models}
///
class V2TimRecvGroupTextMessage {
  late String msgID;
  late V2TimUserInfo sender;
  late String groupID;
  late String? text;

  V2TimRecvGroupTextMessage({
    required this.msgID,
    required this.sender,
    required this.groupID,
    this.text,
  });

  V2TimRecvGroupTextMessage.fromJson(Map<String, dynamic> json) {
    msgID = json['msgID'];
    sender = V2TimUserInfo.fromJson(json['sender']);
    groupID = json['groupID'];
    text = json['customData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msgID'] = msgID;
    data['sender'] = sender.toJson();
    data['groupID'] = groupID;
    data['text'] = text;
    return data;
  }
}
// {
//   "msgID":",",
//   "sender":{},
//   "groupID":"",
//   "customData":""
// }
