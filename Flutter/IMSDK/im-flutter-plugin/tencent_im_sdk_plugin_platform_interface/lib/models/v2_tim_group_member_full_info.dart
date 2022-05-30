/// V2TimGroupMemberFullInfo
///
/// {@category Models}
///
class V2TimGroupMemberFullInfo {
  late String userID;
  late int? role;
  late int? muteUntil;
  late int? joinTime;
  Map<String, String>? customInfo;
  late String? nickName;
  late String? nameCard;
  late String? friendRemark;
  late String? faceUrl;

  V2TimGroupMemberFullInfo({
    required this.userID,
    this.role,
    this.muteUntil,
    this.joinTime,
    this.customInfo,
    this.nickName,
    this.nameCard,
    this.friendRemark,
    this.faceUrl,
  });

  V2TimGroupMemberFullInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    role = json['role'];
    muteUntil = json['muteUntil'];
    joinTime = json['joinTime'];
    customInfo = json['customInfo'] == null
        ? <String, String>{}
        : Map<String, String>.from(json['customInfo']);
    nickName = json['nickName'];
    nameCard = json['nameCard'];
    friendRemark = json['friendRemark'];
    faceUrl = json['faceUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['role'] = role;
    data['muteUntil'] = muteUntil;
    data['joinTime'] = joinTime;
    data['customInfo'] = customInfo;
    data['nickName'] = nickName;
    data['nameCard'] = nameCard;
    data['friendRemark'] = friendRemark;
    data['faceUrl'] = faceUrl;
    return data;
  }
}

// {
//   "userID":"",
//   "role":0,
//   "muteUntil":0,
//   "joinTime":0,
//   "customInfo":{},
//   "nickName":"",
//   "nameCard":"",
//   "friendRemark":"",
//   "faceUrl":""
// }
