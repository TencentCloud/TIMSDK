/// V2TimFriendCheckResult
///
/// {@category Models}
///
class V2TimFriendCheckResult {
  late String userID;
  late int resultCode;
  late String? resultInfo;
  late int resultType;

  V2TimFriendCheckResult({
    required this.userID,
    required this.resultCode,
    this.resultInfo,
    required this.resultType,
  });

  V2TimFriendCheckResult.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    resultCode = json['resultCode'];
    resultInfo = json['resultInfo'];
    resultType = json['resultType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['resultCode'] = this.resultCode;
    data['resultInfo'] = this.resultInfo;
    data['resultType'] = this.resultType;
    return data;
  }
}

// {
//   "userID" : "",
//     "resultCode" : 0,
//     "resultInfo" : "",
//     "resultType" : 0,
// }
