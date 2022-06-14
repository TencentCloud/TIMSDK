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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['resultCode'] = resultCode;
    data['resultInfo'] = resultInfo;
    data['resultType'] = resultType;
    return data;
  }
}

// {
//   "userID" : "",
//     "resultCode" : 0,
//     "resultInfo" : "",
//     "resultType" : 0,
// }
