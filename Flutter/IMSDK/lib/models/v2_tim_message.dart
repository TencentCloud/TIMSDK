import 'package:tencent_im_sdk_plugin/models/v2_tim_merger_elem.dart';
import 'v2_tim_custom_elem.dart';
import 'v2_tim_face_elem.dart';
import 'v2_tim_file_elem.dart';
import 'v2_tim_group_tips_elem.dart';
import 'v2_tim_image_elem.dart';
import 'v2_tim_location_elem.dart';
import 'v2_tim_offline_push_info.dart';
import 'v2_tim_sound_elem.dart';
import 'v2_tim_text_elem.dart';
import 'v2_tim_video_elem.dart';

/// V2TimMessageReceipt
///
/// {@category Models}
///

class V2TimMessage {
  late String? msgID;
  late int? timestamp;
  late int? progress;
  late String? sender;
  late String? nickName;
  late String? friendRemark;
  late String? faceUrl;
  late String? nameCard;
  late String? groupID;
  late String? userID;
  late int? status;
  late int elemType;
  V2TimTextElem? textElem;
  V2TimCustomElem? customElem;
  V2TimImageElem? imageElem;
  V2TimSoundElem? soundElem;
  V2TimVideoElem? videoElem;
  V2TimFileElem? fileElem;
  V2TimLocationElem? locationElem;
  V2TimFaceElem? faceElem;
  V2TimGroupTipsElem? groupTipsElem;
  V2TimMergerElem? mergerElem;
  late String? localCustomData;
  late int? localCustomInt;
  late String? cloudCustomData;
  late bool? isSelf;
  late bool? isRead;
  late bool? isPeerRead;
  late int? priority;
  V2TimOfflinePushInfo? offlinePushInfo;
  List<String>? groupAtUserList = List.empty(growable: true);
  late String? seq;
  late int? random;
  late bool? isExcludedFromUnreadCount;

  V2TimMessage({
    this.msgID,
    this.timestamp,
    this.progress,
    this.sender,
    this.nickName,
    this.friendRemark,
    this.faceUrl,
    this.nameCard,
    this.groupID,
    this.userID,
    this.status,
    required this.elemType,
    this.textElem,
    this.customElem,
    this.imageElem,
    this.soundElem,
    this.videoElem,
    this.fileElem,
    this.locationElem,
    this.faceElem,
    this.groupTipsElem,
    this.mergerElem,
    this.localCustomData,
    this.localCustomInt,
    this.cloudCustomData,
    this.isSelf,
    this.isRead,
    this.isPeerRead,
    this.priority,
    this.offlinePushInfo,
    this.groupAtUserList,
    this.seq,
    this.random,
    this.isExcludedFromUnreadCount,
  });

  V2TimMessage.fromJson(Map<String, dynamic> json) {
    msgID = json['msgID'];
    timestamp = json['timestamp'];
    progress = json['progress'];
    sender = json['sender'];
    nickName = json['nickName'];
    friendRemark = json['friendRemark'];
    faceUrl = json['faceUrl'];
    nameCard = json['nameCard'];
    groupID = json['groupID'];
    userID = json['userID'];
    status = json['status'];
    elemType = json['elemType'];
    textElem = json['textElem'] != null
        ? new V2TimTextElem.fromJson(json['textElem'])
        : null;
    customElem = json['customElem'] != null
        ? new V2TimCustomElem.fromJson(json['customElem'])
        : null;
    imageElem = json['imageElem'] != null
        ? new V2TimImageElem.fromJson(json['imageElem'])
        : null;
    soundElem = json['soundElem'] != null
        ? new V2TimSoundElem.fromJson(json['soundElem'])
        : null;
    videoElem = json['videoElem'] != null
        ? new V2TimVideoElem.fromJson(json['videoElem'])
        : null;
    fileElem = json['fileElem'] != null
        ? new V2TimFileElem.fromJson(json['fileElem'])
        : null;
    locationElem = json['locationElem'] != null
        ? new V2TimLocationElem.fromJson(json['locationElem'])
        : null;
    faceElem = json['faceElem'] != null
        ? new V2TimFaceElem.fromJson(json['faceElem'])
        : null;
    groupTipsElem = json['groupTipsElem'] != null
        ? new V2TimGroupTipsElem.fromJson(json['groupTipsElem'])
        : null;
    mergerElem = json['mergerElem'] != null
        ? new V2TimMergerElem.fromJson(json['mergerElem'])
        : null;
    localCustomData = json['localCustomData'];
    localCustomInt = json['localCustomInt'];
    cloudCustomData = json['cloudCustomData'];
    isSelf = json['isSelf'];
    isRead = json['isRead'];
    isPeerRead = json['isPeerRead'];
    priority = json['priority'];
    offlinePushInfo = json['offlinePushInfo'] != null
        ? new V2TimOfflinePushInfo.fromJson(json['offlinePushInfo'])
        : null;
    groupAtUserList = json['groupAtUserList'] != null
        ? json['groupAtUserList'].cast<String>()
        : List.empty(growable: true);
    seq = json['seq'];
    random = json['random'];
    isExcludedFromUnreadCount = json['isExcludedFromUnreadCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msgID'] = this.msgID;
    data['timestamp'] = this.timestamp;
    data['progress'] = this.progress;
    data['sender'] = this.sender;
    data['nickName'] = this.nickName;
    data['friendRemark'] = this.friendRemark;
    data['faceUrl'] = this.faceUrl;
    data['nameCard'] = this.nameCard;
    data['groupID'] = this.groupID;
    data['userID'] = this.userID;
    data['status'] = this.status;
    data['elemType'] = this.elemType;
    if (this.textElem != null) {
      data['textElem'] = this.textElem!.toJson();
    }
    if (this.customElem != null) {
      data['customElem'] = this.customElem!.toJson();
    }
    if (this.imageElem != null) {
      data['imageElem'] = this.imageElem!.toJson();
    }
    if (this.soundElem != null) {
      data['soundElem'] = this.soundElem!.toJson();
    }
    if (this.videoElem != null) {
      data['videoElem'] = this.videoElem!.toJson();
    }
    if (this.fileElem != null) {
      data['fileElem'] = this.fileElem!.toJson();
    }
    if (this.locationElem != null) {
      data['locationElem'] = this.locationElem!.toJson();
    }
    if (this.faceElem != null) {
      data['faceElem'] = this.faceElem!.toJson();
    }
    if (this.groupTipsElem != null) {
      data['groupTipsElem'] = this.groupTipsElem!.toJson();
    }
    if (this.mergerElem != null) {
      data['mergerElem'] = this.mergerElem!.toJson();
    }
    data['localCustomData'] = this.localCustomData;
    data['localCustomInt'] = this.localCustomInt;
    data['cloudCustomData'] = this.cloudCustomData;

    data['isSelf'] = this.isSelf;
    data['isRead'] = this.isRead;
    data['isPeerRead'] = this.isPeerRead;
    data['priority'] = this.priority;
    if (this.offlinePushInfo != null) {
      data['offlinePushInfo'] = this.offlinePushInfo!.toJson();
    }
    if (this.groupAtUserList != null) {
      data['groupAtUserList'] = this.groupAtUserList;
    }
    data['seq'] = this.seq;
    data['random'] = this.random;
    data['isExcludedFromUnreadCount'] = this.isExcludedFromUnreadCount;
    return data;
  }
}
// {
//   "msgID":"",
//     "timestamp":0,
//     "progress":100,
//     "sender":"",
//     "nickName":"",
//     "friendRemark":"",
//     "faceUrl":"",
//     "nameCard":"",
//     "groupID":"",
//     "userID":"",
//     "status":1,
//     "elemType":1,
//     "textElem":{},
//     "customElem":{},
//     "imageElem":{},
//     "soundElem":{},
//     "videoElem":{},
//     "fileElem":{},
//     "locationElem":{},
//     "faceElem":{},
//     "groupTipsElem":{},
//     "mergerElem":{},
//     "localCustomData":"",
//     "localCustomInt":0,
//     "isSelf":false,
//     "isRead":false,
//     "isPeerRead":false,
//     "priority":0,
//     "offlinePushInfo":{},
//     "groupAtUserList":[{}],
//     "seq":0,
//     "random":0,
//     "isExcludedFromUnreadCount":false
// }
