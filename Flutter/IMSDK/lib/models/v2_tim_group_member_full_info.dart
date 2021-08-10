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
        ? new Map<String, String>()
        : Map<String, String>.from(json['customInfo']);
    nickName = json['nickName'];
    nameCard = json['nameCard'];
    friendRemark = json['friendRemark'];
    faceUrl = json['faceUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['role'] = this.role;
    data['muteUntil'] = this.muteUntil;
    data['joinTime'] = this.joinTime;
    data['customInfo'] = this.customInfo;
    data['nickName'] = this.nickName;
    data['nameCard'] = this.nameCard;
    data['friendRemark'] = this.friendRemark;
    data['faceUrl'] = this.faceUrl;
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
