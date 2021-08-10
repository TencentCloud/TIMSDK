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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['fromUser'] = this.fromUser;
    data['fromUserNickName'] = this.fromUserNickName;
    data['fromUserFaceUrl'] = this.fromUserFaceUrl;
    data['toUser'] = this.toUser;
    data['addTime'] = this.addTime;
    data['requestMsg'] = this.requestMsg;
    data['handledMsg'] = this.handledMsg;
    data['type'] = this.type;
    data['handleStatus'] = this.handleStatus;
    data['handleResult'] = this.handleResult;
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
