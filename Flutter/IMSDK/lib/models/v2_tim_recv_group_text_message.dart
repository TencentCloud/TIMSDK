import 'package:tencent_im_sdk_plugin/models/v2_tim_user_info.dart';

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
    sender = new V2TimUserInfo.fromJson(json['sender']);
    groupID = json['groupID'];
    text = json['customData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msgID'] = this.msgID;
    data['sender'] = this.sender.toJson();
    data['groupID'] = this.groupID;
    data['text'] = this.text;
    return data;
  }
}
// {
//   "msgID":",",
//   "sender":{},
//   "groupID":"",
//   "customData":""
// }
