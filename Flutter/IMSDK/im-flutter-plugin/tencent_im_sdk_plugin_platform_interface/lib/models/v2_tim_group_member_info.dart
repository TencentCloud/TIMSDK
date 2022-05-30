class V2TimGroupMemberInfo {
  String? userID;
  String? nickName;
  String? nameCard;
  String? friendRemark;
  String? faceUrl;

  V2TimGroupMemberInfo({
    this.userID,
    this.nickName,
    this.nameCard,
    this.friendRemark,
    this.faceUrl,
  });

  V2TimGroupMemberInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickName = json['nickName'];
    nameCard = json['nameCard'];
    friendRemark = json['friendRemark'];
    faceUrl = json['faceUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['nickName'] = nickName;
    data['nameCard'] = nameCard;
    data['friendRemark'] = friendRemark;
    data['faceUrl'] = faceUrl;
    return data;
  }
}

// {
//   "userID":"",
//   "nickName":"",
//   "nameCard":"",
//   "friendRemark":"",
//   "faceUrl":""
// }
