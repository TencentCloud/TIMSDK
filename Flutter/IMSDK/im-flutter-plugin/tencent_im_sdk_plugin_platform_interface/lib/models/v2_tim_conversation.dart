
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';

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
  int? orderkey;
  List<int?>? markList;
  String? customData;
  List<String?>? conversationGroupList;

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
    this.orderkey,
    this.markList,
    this.customData,
    this.conversationGroupList,
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
    orderkey = json['orderkey'];
    lastMessage = json['lastMessage'] != null
        ? V2TimMessage.fromJson(json['lastMessage'])
        : null;
    draftText = json['draftText'];
    customData = json['customData'];
    draftTimestamp = json['draftTimestamp'];
    if(json['markList']!=null){
      markList = List.empty(growable: true);
      json['markList'].forEach((v){
        markList?.add(v);
      });
    }
    if(json['conversationGroupList']!=null){
      conversationGroupList = List.empty(growable: true);
      json['conversationGroupList'].forEach((v){
        conversationGroupList?.add(v);
      });
    }
    
    if (json['groupAtInfoList'] != null) {
      groupAtInfoList = List.empty(growable: true);
      json['groupAtInfoList'].forEach((v) {
        groupAtInfoList!.add(V2TimGroupAtInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationID'] = conversationID;
    data['type'] = type;
    data['userID'] = userID;
    data['groupID'] = groupID;
    data['showName'] = showName;
    data['faceUrl'] = faceUrl;
    data['groupType'] = groupType;
    data['unreadCount'] = unreadCount;
    data['isPinned'] = isPinned;
    data['recvOpt'] = recvOpt;
    data['orderkey'] = orderkey;
    data['customData'] = customData;
    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }
    data['draftText'] = draftText;
    data['draftTimestamp'] = draftTimestamp;
    if (groupAtInfoList != null) {
      data['groupAtInfoList'] =
          groupAtInfoList!.map((v) => v!.toJson()).toList();
    }
    if (conversationGroupList != null) {
      data['conversationGroupList'] =
          conversationGroupList!.map((v) => v).toList();
    }
    if (markList != null) {
      data['markList'] =
          markList!.map((v) => v).toList();
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
