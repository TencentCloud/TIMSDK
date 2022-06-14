import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_merger_elem.dart';
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
  late bool? isExcludedFromLastMessage;
  late String? messageFromWeb;
  late String? id; // plugin自己维护的id，在onProgressListener的监听中才返回
  late bool? needReadReceipt;

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
    this.isExcludedFromLastMessage,
    this.messageFromWeb,
    this.id,
    this.needReadReceipt,
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
    id = json['id'];
    needReadReceipt = json['needReadReceipt'];
    textElem = json['textElem'] != null
        ? V2TimTextElem.fromJson(json['textElem'])
        : null;
    customElem = json['customElem'] != null
        ? V2TimCustomElem.fromJson(json['customElem'])
        : null;
    imageElem = json['imageElem'] != null
        ? V2TimImageElem.fromJson(json['imageElem'])
        : null;
    soundElem = json['soundElem'] != null
        ? V2TimSoundElem.fromJson(json['soundElem'])
        : null;
    videoElem = json['videoElem'] != null
        ? V2TimVideoElem.fromJson(json['videoElem'])
        : null;
    fileElem = json['fileElem'] != null
        ? V2TimFileElem.fromJson(json['fileElem'])
        : null;
    locationElem = json['locationElem'] != null
        ? V2TimLocationElem.fromJson(json['locationElem'])
        : null;
    faceElem = json['faceElem'] != null
        ? V2TimFaceElem.fromJson(json['faceElem'])
        : null;
    groupTipsElem = json['groupTipsElem'] != null
        ? V2TimGroupTipsElem.fromJson(json['groupTipsElem'])
        : null;
    mergerElem = json['mergerElem'] != null
        ? V2TimMergerElem.fromJson(json['mergerElem'])
        : null;
    localCustomData = json['localCustomData'] ?? "";
    localCustomInt = json['localCustomInt'];
    cloudCustomData = json['cloudCustomData'] ?? "";
    isSelf = json['isSelf'];
    isRead = json['isRead'];
    isPeerRead = json['isPeerRead'];
    priority = json['priority'];
    offlinePushInfo = json['offlinePushInfo'] != null
        ? V2TimOfflinePushInfo.fromJson(json['offlinePushInfo'])
        : null;
    groupAtUserList = json['groupAtUserList'] != null
        ? json['groupAtUserList'].cast<String>()
        : List.empty(growable: true);
    seq = json['seq'];
    random = json['random'];
    isExcludedFromUnreadCount = json['isExcludedFromUnreadCount'];
    isExcludedFromLastMessage = json['isExcludedFromLastMessage'];
    messageFromWeb = json['messageFromWeb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msgID'] = msgID;
    data['timestamp'] = timestamp;
    data['progress'] = progress;
    data['sender'] = sender;
    data['nickName'] = nickName;
    data['friendRemark'] = friendRemark;
    data['faceUrl'] = faceUrl;
    data['nameCard'] = nameCard;
    data['groupID'] = groupID;
    data['userID'] = userID;
    data['status'] = status;
    data['elemType'] = elemType;
    data['id'] = id;
    data['needReadReceipt'] = needReadReceipt;
    if (textElem != null) {
      data['textElem'] = textElem!.toJson();
    }
    if (customElem != null) {
      data['customElem'] = customElem!.toJson();
    }
    if (imageElem != null) {
      data['imageElem'] = imageElem!.toJson();
    }
    if (soundElem != null) {
      data['soundElem'] = soundElem!.toJson();
    }
    if (videoElem != null) {
      data['videoElem'] = videoElem!.toJson();
    }
    if (fileElem != null) {
      data['fileElem'] = fileElem!.toJson();
    }
    if (locationElem != null) {
      data['locationElem'] = locationElem!.toJson();
    }
    if (faceElem != null) {
      data['faceElem'] = faceElem!.toJson();
    }
    if (groupTipsElem != null) {
      data['groupTipsElem'] = groupTipsElem!.toJson();
    }
    if (mergerElem != null) {
      data['mergerElem'] = mergerElem!.toJson();
    }
    data['localCustomData'] = localCustomData;
    data['localCustomInt'] = localCustomInt;
    data['cloudCustomData'] = cloudCustomData;

    data['isSelf'] = isSelf;
    data['isRead'] = isRead;
    data['isPeerRead'] = isPeerRead;
    data['priority'] = priority;
    if (offlinePushInfo != null) {
      data['offlinePushInfo'] = offlinePushInfo!.toJson();
    }
    if (groupAtUserList != null) {
      data['groupAtUserList'] = groupAtUserList;
    }
    data['seq'] = seq;
    data['random'] = random;
    data['isExcludedFromUnreadCount'] = isExcludedFromUnreadCount;
    data['isExcludedFromLastMessage'] = isExcludedFromLastMessage;
    data['messageFromWeb'] = messageFromWeb;
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
