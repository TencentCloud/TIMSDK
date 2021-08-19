/// V2TIMGroupMemberChangeInfo
///
/// {@category Models}
///
class V2TimGroupMemberChangeInfo {
  String? userID;
  int? muteTime;

  V2TimGroupMemberChangeInfo({
    this.userID,
    this.muteTime,
  });

  V2TimGroupMemberChangeInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    muteTime = json['muteTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['muteTime'] = this.muteTime;
    return data;
  }
}

// {
//   "userID":"",
//   "muteTime":0
// }
