/// V2TimMessageReceipt
///
/// {@category Models}
///
class V2TimMessageReceipt {
  late String userID;
  late int timestamp;
  late String? groupID;
  late String? msgID;
  late int? readCount;
  late int? unreadCount;

  V2TimMessageReceipt(
      {required this.userID,
      required this.timestamp,
      this.groupID,
      this.msgID,
      this.readCount,
      this.unreadCount});

  V2TimMessageReceipt.fromJson(Map<String, dynamic> json) {
    userID = json['userID'] ?? "";
    timestamp = json['timestamp'];
    msgID = json['msgID'] ?? "";
    readCount = json['readCount'];
    unreadCount = json['unreadCount'];
    groupID = json['groupID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['timestamp'] = timestamp;
    data['groupID'] = groupID ?? "";
    data['msgID'] = msgID;
    data['readCount'] = readCount;
    data['unreadCount'] = unreadCount;
    return data;
  }
}

// {
//   "userID":"",
//   "timestamp":0
// }
