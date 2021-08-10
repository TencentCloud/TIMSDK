/// V2TimFriendApplication
///
/// {@category Models}
///
class V2TimFriendApplication {
  late String userID;
  late String? nickname;
  late String? faceUrl;
  late int? addTime;
  late String? addSource;
  late String? addWording;
  late int type;

  V2TimFriendApplication({
    required this.userID,
    this.nickname,
    this.faceUrl,
    this.addTime,
    this.addSource,
    this.addWording,
    required this.type,
  });

  V2TimFriendApplication.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickname = json['nickname'];
    faceUrl = json['faceUrl'];
    addTime = json['addTime'];
    addSource = json['addSource'];
    addWording = json['addWording'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['nickname'] = this.nickname;
    data['faceUrl'] = this.faceUrl;
    data['addTime'] = this.addTime;
    data['addSource'] = this.addSource;
    data['addWording'] = this.addWording;
    data['type'] = this.type;
    return data;
  }
}

// {
//   "userID":"",
//   "nickname":"",
//   "faceUrl":"",
//   "addTime":0,
//   "addSource":"",
//   "addWording":"",
//   "type":1
// }
