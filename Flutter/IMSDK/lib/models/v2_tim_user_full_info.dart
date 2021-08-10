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
  });

  V2TimUserFullInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickName = json['nickName'];
    faceUrl = json['faceUrl'];
    selfSignature = json['selfSignature'];
    gender = json['gender'];
    allowType = json['allowType'];
    customInfo = json['customInfo'] == null
        ? new Map<String, String>()
        : Map<String, String>.from(json['customInfo']);
    role = json['role'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['nickName'] = this.nickName;
    data['faceUrl'] = this.faceUrl;
    data['selfSignature'] = this.selfSignature;
    data['gender'] = this.gender;
    data['allowType'] = this.allowType;
    data['customInfo'] = this.customInfo;
    data['role'] = this.role;
    data['level'] = this.level;
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
