/// V2TimGroupApplication
///
/// {@category Models}
///
class V2TimGroupApplication {
  late String groupID;
  late String? fromUser;
  late String? fromUserNickName;
  late String? fromUserFaceUrl;
  late String? toUser;
  late int? addTime;
  late String? requestMsg;
  late String? handledMsg;
  late int type;
  late int handleStatus;
  late int handleResult;

  V2TimGroupApplication({
    required this.groupID,
    this.fromUser,
    this.fromUserNickName,
    this.fromUserFaceUrl,
    this.toUser,
    this.addTime,
    this.requestMsg,
    this.handledMsg,
    required this.type,
    required this.handleStatus,
    required this.handleResult,
  });

  V2TimGroupApplication.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    fromUser = json['fromUser'];
    fromUserNickName = json['fromUserNickName'];
    fromUserFaceUrl = json['fromUserFaceUrl'];
    toUser = json['toUser'];
    addTime = json['addTime'];
    requestMsg = json['requestMsg'];
    handledMsg = json['handledMsg'];
    type = json['type'];
    handleStatus = json['handleStatus'];
    handleResult = json['handleResult'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['fromUser'] = fromUser;
    data['fromUserNickName'] = fromUserNickName;
    data['fromUserFaceUrl'] = fromUserFaceUrl;
    data['toUser'] = toUser;
    data['addTime'] = addTime;
    data['requestMsg'] = requestMsg;
    data['handledMsg'] = handledMsg;
    data['type'] = type;
    data['handleStatus'] = handleStatus;
    data['handleResult'] = handleResult;
    return data;
  }
}

// {
//   "groupID":"",
//   "fromUser":"",
//    "fromUserNickName":"",
//    "fromUserFaceUrl":"",
//    "toUser":"",
//    "addTime":0,
//    "requestMsg":"",
//    "handledMsg":"",
//    "type":0,
//    "handleStatus":0,
//    "handleResult":0
// }
