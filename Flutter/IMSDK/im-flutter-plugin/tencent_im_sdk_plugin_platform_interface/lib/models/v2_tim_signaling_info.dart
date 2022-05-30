import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_offline_push_info.dart';

/// V2TimSignalingInfo
///
/// {@category Models}
///
class V2TimSignalingInfo {
  late String inviteID; // 邀请ID
  late String inviter; // 邀请人ID
  late List<dynamic> inviteeList;
  String? groupID;
  String? data;
  int? timeout;
  late int actionType;
  late int? businessID; // ios不回返回这条
  late bool? isOnlineUserOnly; // ios不回返回这条
  late V2TimOfflinePushInfo? offlinePushInfo; // ios不回返回这条
  V2TimSignalingInfo({
    required this.inviteID,
    required this.inviter,
    required this.inviteeList,
    required this.actionType,
    required this.businessID,
    required this.isOnlineUserOnly,
    required this.offlinePushInfo,
    this.groupID,
    this.data,
    this.timeout,
  });

  V2TimSignalingInfo.fromJson(Map<String, dynamic> json) {
    inviteID = json['inviteID'];
    groupID = json['groupID'];
    inviter = json['inviter'];
    inviteeList = json['inviteeList'];
    data = json['data'];
    timeout = json['timeout'];
    actionType = json['actionType'];
    // 下方三个参数ios不会返回
    if (json['businessID'] != null) businessID = json['businessID'];
    if (json['isOnlineUserOnly'] != null) {
      isOnlineUserOnly = json['isOnlineUserOnly'];
    }
    if (json['offlinePushInfo'] != null) {
      offlinePushInfo = V2TimOfflinePushInfo.fromJson(json['offlinePushInfo']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inviteID'] = inviteID;
    data['groupID'] = groupID;
    data['inviter'] = inviter;
    data['inviteeList'] = inviteeList;
    data['data'] = this.data;
    data['timeout'] = timeout;
    data['actionType'] = actionType;
    // 下方三个参数ios不会返回
    if (data['businessID'] != null) data['businessID'] = businessID;
    if (data['businessID'] != null) {
      data['isOnlineUserOnly'] = isOnlineUserOnly;
    }
    if (data['offlinePushInfo'] != null) {
      data['offlinePushInfo'] = offlinePushInfo?.toJson();
    }
    return data;
  }
}
