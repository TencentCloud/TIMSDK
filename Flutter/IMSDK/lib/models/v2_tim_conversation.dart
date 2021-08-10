import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'v2_tim_group_at_info.dart';

/// V2TimConversation
///
/// {@category Models}
///
class V2TimConversation {
  late String conversationID;
  int? type;
  String? userID;
  String? groupID;
  String? showName;
  String? faceUrl;
  String? groupType;
  int? unreadCount;
  V2TimMessage? lastMessage;
  String? draftText;
  int? draftTimestamp;
  bool? isPinned;
  int? recvOpt;
  List<V2TimGroupAtInfo?>? groupAtInfoList = List.empty(growable: true);

  V2TimConversation({
    required this.conversationID,
    this.type,
    this.userID,
    this.groupID,
    this.showName,
    this.faceUrl,
    this.groupType,
    this.unreadCount,
    this.lastMessage,
    this.draftText,
    this.draftTimestamp,
    this.groupAtInfoList,
    this.isPinned,
    this.recvOpt,
  });

  V2TimConversation.fromJson(Map<String, dynamic> json) {
    conversationID = json['conversationID'];
    type = json['type'];
    userID = json['userID'];
    groupID = json['groupID'];
    showName = json['showName'];
    faceUrl = json['faceUrl'];
    groupType = json['groupType'];
    unreadCount = json['unreadCount'];
    isPinned = json['isPinned'];
    recvOpt = json['recvOpt'];
    lastMessage = json['lastMessage'] != null
        ? new V2TimMessage.fromJson(json['lastMessage'])
        : null;
    draftText = json['draftText'];
    draftTimestamp = json['draftTimestamp'];
    if (json['groupAtInfoList'] != null) {
      groupAtInfoList = List.empty(growable: true);
      json['groupAtInfoList'].forEach((v) {
        groupAtInfoList!.add(V2TimGroupAtInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['conversationID'] = this.conversationID;
    data['type'] = this.type;
    data['userID'] = this.userID;
    data['groupID'] = this.groupID;
    data['showName'] = this.showName;
    data['faceUrl'] = this.faceUrl;
    data['groupType'] = this.groupType;
    data['unreadCount'] = this.unreadCount;
    data['isPinned'] = this.isPinned;
    data['recvOpt'] = this.recvOpt;
    if (this.lastMessage != null) {
      data['lastMessage'] = this.lastMessage!.toJson();
    }
    data['draftText'] = this.draftText;
    data['draftTimestamp'] = this.draftTimestamp;
    if (this.groupAtInfoList != null) {
      data['groupAtInfoList'] =
          this.groupAtInfoList!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}
// {
//   "conversationID":"",
//   "type":0,
//   "userID":"",
//   "groupID":"",
//   "showName":"",
//   "faceUrl":"",
// "groupType":"",
// "unreadCount":0,
// "lastMessage":{},
// "draftText":"",
// "draftTimestamp":0,
// "groupAtInfoList":[{}]
// }
