import 'v2_tim_user_info.dart';

/// V2TimRecvC2cTextMessage
///
/// {@category Models}
///
class V2TimRecvC2cTextMessage {
  late String msgID;
  late V2TimUserInfo sender;
  late String? text;

  V2TimRecvC2cTextMessage({
    required this.msgID,
    required this.sender,
    this.text,
  });

  V2TimRecvC2cTextMessage.fromJson(Map<String, dynamic> json) {
    msgID = json['msgID'];
    sender = new V2TimUserInfo.fromJson(json['sender']);
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msgID'] = this.msgID;
    data['sender'] = this.sender.toJson();
    data['text'] = this.text;
    return data;
  }
}
// {
//   "msgID":"",
//   "sender":{},
//   "text":""
// }
