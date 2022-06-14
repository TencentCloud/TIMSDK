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
  bool? isSupportTopic = false;
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
    this.isSupportTopic,
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
    isSupportTopic = json["isSupportTopic"];
    role = json['role'];
    recvOpt = json['recvOpt'];
    joinTime = json['joinTime'];
    customInfo = json['customInfo'] == null
        ? <String, String>{}
        : Map<String, String>.from(json['customInfo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupID'] = groupID;
    data['groupType'] = groupType;
    data['groupName'] = groupName;
    data['notification'] = notification;
    data['introduction'] = introduction;
    data['faceUrl'] = faceUrl;
    data['isAllMuted'] = isAllMuted;
    data['owner'] = owner;
    data['createTime'] = createTime;
    data['groupAddOpt'] = groupAddOpt;
    data['lastInfoTime'] = lastInfoTime;
    data['lastMessageTime'] = lastMessageTime;
    data['memberCount'] = memberCount;
    data['onlineCount'] = onlineCount;
    data['role'] = role;
    data['recvOpt'] = recvOpt;
    data['joinTime'] = joinTime;
    data['customInfo'] = customInfo;
    data['isSupportTopic'] = isSupportTopic;
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
