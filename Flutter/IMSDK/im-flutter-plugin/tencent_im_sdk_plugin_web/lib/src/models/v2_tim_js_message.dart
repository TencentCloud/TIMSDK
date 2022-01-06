import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class V2TIMJSMessage {
  late String? ID;
  late String? type;
  late Map<String, dynamic>? payload;
  late String? conversationID;
  late String? conversationType;
  late String? to;
  late String? from;
  late String? flow;
  late String? status;
  late String? priority;
  late String? nick;
  late String? avatar;
  late String? nameCard;
  late int? time;
  late bool? isRevoked;
  late bool? isPeerRead;
  late bool? isDeleted;
  late bool? isModified;
  late List<dynamic>? atUserList;
  late String cloudCustomData;
  late bool? isRead;
  late int? sequence;
  late int? random;

  V2TIMJSMessage.fromJSON(Map<String, dynamic> json) {
    ID = json["ID"];
    type = json["type"];
    payload = jsToMap(json["payload"]);
    conversationID = json["conversationID"];
    conversationType = json["conversationType"];
    to = json["to"];
    from = json["from"];
    flow = json["flow"];
    status = json["status"];
    priority = json["priority"];
    nick = json["nick"];
    avatar = json["avatar"];
    nameCard = json["nameCard"];
    time = json["time"];
    isRevoked = json["isRevoked"];
    isPeerRead = json["isPeerRead"];
    isDeleted = json["isDeleted"];
    isModified = json["isModified"];
    atUserList = json["atUserList"];
    cloudCustomData = json["cloudCustomData"];
    isRead = json["isRead"];
    sequence = json["sequence"];
    random = json["random"];
  }
}
