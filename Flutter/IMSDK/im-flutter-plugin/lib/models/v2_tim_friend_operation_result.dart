/// V2TimFriendOperationResult
///
/// {@category Models}
///
class V2TimFriendOperationResult {
  late String userID;
  late int? resultCode;
  late String? resultInfo;

  V2TimFriendOperationResult({
    required this.userID,
    this.resultCode,
    this.resultInfo,
  });

  V2TimFriendOperationResult.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    resultCode = json['resultCode'];
    resultInfo = json['resultInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['resultCode'] = this.resultCode;
    data['resultInfo'] = this.resultInfo;
    return data;
  }
}
// {
//   "userID":"",
//   "resultCode":0,
//   "resultInfo":""
// }
