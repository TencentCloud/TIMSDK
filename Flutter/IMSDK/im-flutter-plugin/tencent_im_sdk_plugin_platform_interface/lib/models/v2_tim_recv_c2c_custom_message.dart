import 'v2_tim_user_info.dart';

/// V2TimRecvC2cCustomMessage
///
/// {@category Models}
///
class V2TimRecvC2cCustomMessage {
  late String msgID;
  late V2TimUserInfo sender;
  late String? customData;

  V2TimRecvC2cCustomMessage({
    required this.msgID,
    required this.sender,
    this.customData,
  });

  V2TimRecvC2cCustomMessage.fromJson(Map<String, dynamic> json) {
    msgID = json['msgID'];
    sender = V2TimUserInfo.fromJson(json['sender']);
    customData = json['customData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msgID'] = msgID;
    data['sender'] = sender.toJson();
    data['customData'] = customData;
    return data;
  }
}
// {
//   "msgID":"",
//   "sender":{},
//   "customData":""
// }
