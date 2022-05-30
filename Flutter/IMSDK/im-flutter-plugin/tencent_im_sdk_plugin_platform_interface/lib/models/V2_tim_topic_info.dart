// ignore_for_file: file_names

import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';

/// V2TimTopicInfo
///
/// {@category Models}
///
class V2TimTopicInfo {
   String? topicID;
  String? topicName;
  String? topicFaceUrl;
  String? introduction;
  String? notification;
  bool? isAllMute = false;
  int? selfMuteTime;
  String? customString;
   int? recvOpt;
  String? draftText;
  int? unreadCount = 0;
  V2TimMessage? lastMessage;
  List<V2TimGroupAtInfo>? groupAtInfoList = List.empty(growable: true);

  V2TimTopicInfo({
    this.topicID,
    this.topicName,
    this.topicFaceUrl,
    this.introduction,
    this.notification,
    this.isAllMute,
    this.selfMuteTime,
    this.customString,
    this.draftText,
    this.unreadCount,
    this.lastMessage,
    this.groupAtInfoList,
  });
  V2TimTopicInfo.fromJson(Map<String, dynamic> json) {
   topicID = json['topicID'];
   topicName = json['topicName'];
   topicFaceUrl = json['topicFaceUrl'];
   introduction = json['introduction'];
   notification = json['notification'];
   isAllMute = json['isAllMute'];
   selfMuteTime = json['selfMuteTime'];
   customString = json['customString'];
   draftText = json['draftText'];
   unreadCount = json['unreadCount'];
    if(json['lastMessage']!=null){
      lastMessage = V2TimMessage.fromJson(json['lastMessage']);
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
    data['topicID'] = topicID;
    data['topicName'] = topicName;
    data['topicFaceUrl'] = topicFaceUrl;
    data['introduction'] = introduction;
    data['notification'] = notification;
    data['isAllMute'] = isAllMute;
    data['selfMuteTime'] = selfMuteTime;
    data['customString'] = customString;
    data['draftText'] = draftText;
    data['unreadCount'] = unreadCount;
    data['lastMessage'] = lastMessage?.toJson();
    if (groupAtInfoList != null) {
      data['groupAtInfoList'] = groupAtInfoList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}