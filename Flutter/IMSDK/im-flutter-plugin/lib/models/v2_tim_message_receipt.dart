/// V2TimMessageReceipt
///
/// {@category Models}
///
class V2TimMessageReceipt {
  late String userID;
  late int timestamp;

  V2TimMessageReceipt({
    required this.userID,
    required this.timestamp,
  });

  V2TimMessageReceipt.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

// {
//   "userID":"",
//   "timestamp":0
// }
