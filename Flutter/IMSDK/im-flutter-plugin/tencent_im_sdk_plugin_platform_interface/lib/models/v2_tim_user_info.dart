/// V2TimUserInfo
///
/// {@category Models}
///
class V2TimUserInfo {
  late String userID;
  late String? nickName;
  late String? faceUrl;

  V2TimUserInfo({
    required this.userID,
    this.nickName,
    this.faceUrl,
  });

  V2TimUserInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickName = json['nickName'];
    faceUrl = json['faceUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['nickName'] = this.nickName;
    data['faceUrl'] = this.faceUrl;
    return data;
  }
}

// {
//   "userID":"",
//   "nickName":"",
//   "faceUrl":""
// }
