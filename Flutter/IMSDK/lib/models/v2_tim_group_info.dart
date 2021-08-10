/// V2TimGroupInfo
///
/// {@category Models}
///
class V2TimGroupInfo {
  late String groupID;
  late String groupType;
  late String? groupName;
  late String? notification;
  late String? introduction;
  late String? faceUrl;
  late bool? isAllMuted;
  late String? owner;
  late int? createTime;
  late int? groupAddOpt;
  late int? lastInfoTime;
  late int? lastMessageTime;
  late int? memberCount;
  late int? onlineCount;
  late int? role;
  late int? recvOpt;
  late int? joinTime;
  Map<String, String>? customInfo;

  V2TimGroupInfo({
    required this.groupID,
    required this.groupType,
    this.groupName,
    this.notification,
    this.introduction,
    this.faceUrl,
    this.isAllMuted,
    this.owner,
    this.createTime,
    this.groupAddOpt,
    this.lastInfoTime,
    this.lastMessageTime,
    this.memberCount,
    this.onlineCount,
    this.role,
    this.recvOpt,
    this.joinTime,
    this.customInfo,
  });

  V2TimGroupInfo.fromJson(Map<String, dynamic> json) {
    groupID = json['groupID'];
    groupType = json['groupType'];
    groupName = json['groupName'];
    notification = json['notification'];
    introduction = json['introduction'];
    faceUrl = json['faceUrl'];
    isAllMuted = json['isAllMuted'];
    owner = json['owner'];
    createTime = json['createTime'];
    groupAddOpt = json['groupAddOpt'];
    lastInfoTime = json['lastInfoTime'];
    lastMessageTime = json['lastMessageTime'];
    memberCount = json['memberCount'];
    onlineCount = json['onlineCount'];
    role = json['role'];
    recvOpt = json['recvOpt'];
    joinTime = json['joinTime'];
    customInfo = json['customInfo'] == null
        ? new Map<String, String>()
        : Map<String, String>.from(json['customInfo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupID'] = this.groupID;
    data['groupType'] = this.groupType;
    data['groupName'] = this.groupName;
    data['notification'] = this.notification;
    data['introduction'] = this.introduction;
    data['faceUrl'] = this.faceUrl;
    data['isAllMuted'] = this.isAllMuted;
    data['owner'] = this.owner;
    data['createTime'] = this.createTime;
    data['groupAddOpt'] = this.groupAddOpt;
    data['lastInfoTime'] = this.lastInfoTime;
    data['lastMessageTime'] = this.lastMessageTime;
    data['memberCount'] = this.memberCount;
    data['onlineCount'] = this.onlineCount;
    data['role'] = this.role;
    data['recvOpt'] = this.recvOpt;
    data['joinTime'] = this.joinTime;
    data['customInfo'] = this.customInfo;
    return data;
  }
}
// {
//  "groupID":"" ,
//  "groupType":"",
//  "groupName":"",
//  "notification":"",
//  "introduction":"",
//  "faceUrl":"",
//  "allMuted":false,
//  "owner":"",
//  "createTime":0,
//  "groupAddOpt":0,
//  "lastInfoTime":0,
//  "lastMessageTime":0,
//  "memberCount":0,
//  "onlineCount":0,
//  "role":0,
//  "recvOpt":0,
//  "joinTime":0,
//  "customInfo":{}
// }
