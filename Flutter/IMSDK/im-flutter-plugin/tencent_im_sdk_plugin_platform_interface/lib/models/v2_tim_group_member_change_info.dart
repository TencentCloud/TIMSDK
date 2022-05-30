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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['muteTime'] = muteTime;
    return data;
  }
}

// {
//   "userID":"",
//   "muteTime":0
// }
