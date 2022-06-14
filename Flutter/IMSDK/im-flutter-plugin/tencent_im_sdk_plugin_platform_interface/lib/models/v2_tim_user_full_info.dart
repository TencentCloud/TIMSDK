/// V2TimUserFullInfo
///
/// {@category Models}
///
class V2TimUserFullInfo {
  late String? userID;
  late String? nickName;
  late String? faceUrl;
  late String? selfSignature;
  late int? gender;
  late int? allowType;
  late Map<String, String>? customInfo;
  late int? role;
  late int? level;
  late int? birthday;

  V2TimUserFullInfo({
    this.userID,
    this.nickName,
    this.faceUrl,
    this.selfSignature,
    this.gender,
    this.allowType,
    this.customInfo,
    this.role,
    this.level,
    this.birthday,
  });

  V2TimUserFullInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickName = json['nickName'];
    faceUrl = json['faceUrl'];
    selfSignature = json['selfSignature'];
    gender = json['gender'];
    allowType = json['allowType'];
    customInfo = json['customInfo'] == null
        ? <String, String>{}
        : Map<String, String>.from(json['customInfo']);
    role = json['role'];
    level = json['level'];
    birthday = json['birthday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['nickName'] = nickName;
    data['faceUrl'] = faceUrl;
    data['selfSignature'] = selfSignature;
    data['gender'] = gender;
    data['allowType'] = allowType;
    data['customInfo'] = customInfo;
    data['role'] = role;
    data['level'] = level;
    data['birthday'] = birthday;
    return data;
  }
}
// {
//   "userID":"",
//   "nickName":"",
//   "faceUrl":"",
//   "selfSignature":"",
//   "gender":0,
//   "allowType":0,
//   "customInfo":{"test":""},
//   "role":0,
//   "level":0
// }
