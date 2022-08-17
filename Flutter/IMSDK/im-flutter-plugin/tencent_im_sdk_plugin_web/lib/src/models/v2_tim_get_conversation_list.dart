// ignore_for_file: unused_import

import 'dart:convert';

import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_custom_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_face_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_file_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_image.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_image_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_location_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_merger_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_text_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_video_elem.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/message_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class GetConversationList {
  late String conversationID;
  late int count;

  static formateParams(Map<String, dynamic> data) {
    Map<String, dynamic> params = <String, dynamic>{};
    params["conversationID"] = data["conversationID"];
    params["count"] = data["count"];

    return mapToJSObj(params);
  }

  // getConversationList没有这两个字段
  static Map<String, dynamic> formatReturn(List<dynamic> list) {
    return {
      "nextSeq": "1",
      "isFinished": true,
      "conversationList": list,
    };
  }

  // 将js的数据结构dart化,这里每层为了兼容dart都需要做细致化处理，不然返回回去的某些类型就会报错
  static formateConversationList(dynamic conversationListJs) async {
    final conversationList = [];

    for (var i = 0; i < conversationListJs.length; i++) {
      final item =
          await formateConversationListItem(jsToMap(conversationListJs[i]));
      conversationList.add(item);
    }

    return conversationList;
  }

  static formateConversationListItem(Map<String, dynamic> itemJS) async {
    Map<String, dynamic> conversationListItem = itemJS;
    final originalConversationID = itemJS['conversationID'] as String;
    var formatedConversationID = "";
    formatedConversationID = originalConversationID.replaceAll("C2C", "c2c_");
    formatedConversationID =
        formatedConversationID.replaceAll("GROUP", "group_");

    conversationListItem["friendRemark"] = itemJS['remark'];
    conversationListItem["conversationID"] = formatedConversationID;

    if (itemJS['lastMessage'] != null) {
      conversationListItem["lastMessage"] =
          await formateLasteMessage(jsToMap(itemJS['lastMessage']));
    }

    // 这个是web特有，其中的属性，在ios都是外层
    if (itemJS['groupProfile'] != null) {
      final groupProfile = jsToMap(itemJS['groupProfile']);
      conversationListItem["groupProfile"] =
          await formateGroupProfile(groupProfile);
      conversationListItem["groupID"] = groupProfile['groupID'];
      conversationListItem["showName"] = getShowName(itemJS);
      conversationListItem["groupType"] = groupProfile['type'];
      conversationListItem["faceUrl"] = groupProfile['avatar'];
    }
    if (itemJS['groupAtInfoList'] != null &&
        itemJS['groupAtInfoList'].length > 0) {
      conversationListItem["groupAtInfoList"] =
          formateGroupAtInfoList(itemJS['groupAtInfoList']);
    }
    if (itemJS['userProfile'] != null) {
      final userProfile = jsToMap(itemJS['userProfile']);
      conversationListItem["userProfile"] = formateUserProfile(userProfile);
      conversationListItem["userID"] = userProfile['userID'];
      conversationListItem["showName"] = getShowName(itemJS);
      conversationListItem["faceUrl"] = userProfile['avatar'];
    }
    conversationListItem["type"] =
        ConversationTypeWeb.convertConverstationtType(itemJS["type"]);

    return conversationListItem;
  }

  //  这个lastMessage有点问题，他缺少的东西有点多，比如没有messageID
  static formateLasteMessage(Map<String, dynamic> message) async {
    final elementType = message['type'] != null
        ? MsgType.convertMsgType(message['type'])
        : null;

    // 直接从消息中的Message中copy过来的,但部分字段有缺失
    final formatedMsg = <String, dynamic>{
      "msgID": message['ID'] ?? '',
      "timestamp": message['lastTime'],
      "progress": 100,
      "sender": message['fromAccount'],
      "nickName": message['nick'],
      "friendRemark": message['remark'],
      // "faceUrl": message.avatar ?? '',
      // "nameCard": message.nameCard,
      // "groupID": message.conversationType == "GROUP" ? message.to : null,
      // "userID": message.conversationType == "C2C" ? message.to : null,
      "status": 2, // unSend sucess fail
      "elemType": elementType,
      "localCustomData": "",
      "localCustomInt": 0,
      "cloudCustomData": message['cloudCustomData'],
      "isSelf": true,
      "isRead": message['isRead'],
      // "isPeerRead": message.isPeerRead > 0 ? true : false,
      // "priority": convertPriorityFromWebToDart(message.priority),
      // "groupAtUserList": message.atUserList,
      // "random": message.random,
      "isExcludedFromUnreadCount": false,
      // "messageFromWeb": stringify(message)
    };

    final messagePayload = jsToMap(message["payload"]);

    // 文本消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      final textElem = V2TimTextElem(text: messagePayload['text']).toJson();
      formatedMsg['textElem'] = textElem;
    }

    // 自定义消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM) {
      final customElem = V2TimCustomElem(
              data: messagePayload['data'],
              desc: messagePayload['discription'],
              extension: messagePayload['extension'])
          .toJson();
      formatedMsg['customElem'] = customElem;
    }

    // 群系统通知消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS) {
      final groupTipsElement =
          await V2TIMMessage.convertGroupTipsMessage(message);
      formatedMsg['groupTipsElem'] = groupTipsElement!.toJson();
    }

    // 图片消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE) {
      final imageInfoArray = messagePayload['imageInfoArray'] as List;
      final imagePath = jsToMap(imageInfoArray[0])['url'];
      final uuid = messagePayload['uuid'];
      final imageList = imageInfoArray.map((e) {
        final element = jsToMap(e);
        return V2TimImage(
            type: element['type'],
            height: element['height'],
            width: element['width'],
            size: element['size'],
            uuid: uuid,
            url: element['imageUrl']);
      }).toList();
      final imageElem = V2TimImageElem(path: imagePath, imageList: imageList);
      formatedMsg['imageElem'] = imageElem.toJson();
    }

    //视频消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_VIDEO) {
      final videoElem = V2TimVideoElem(
          videoPath: messagePayload['videoUrl'],
          duration: messagePayload['videoSecond'],
          UUID: messagePayload['videoUUID'],
          snapshotPath: messagePayload['thumbUrl'],
          snapshotUUID: messagePayload['thumbUUID'],
          snapshotSize: messagePayload['thumbSize'],
          snapshotWidth: messagePayload['thumbWidth'],
          snapshotHeight: messagePayload['thumbHeight'],
          videoUrl: messagePayload['videoUrl'],
          videoSize: messagePayload['videoSize']);
      formatedMsg['videoElem'] = videoElem.toJson();
    }

    // 文件消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_FILE) {
      final fileElem = V2TimFileElem(
              path: messagePayload['fileUrl'],
              fileName: messagePayload['fileName'],
              UUID: messagePayload['uuid'],
              fileSize: messagePayload['fileSize'])
          .toJson();
      formatedMsg['fileElem'] = fileElem;
    }

    // 地理位置消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_LOCATION) {
      final locationElem = V2TimLocationElem(
          desc: messagePayload['description'],
          longitude: messagePayload['longitude'],
          latitude: messagePayload['latitude']);
      formatedMsg['locationElem'] = locationElem.toJson();
    }

    List<String> formateList(List<dynamic> list) =>
        list.map((e) => e.toString()).toList();

    // 合并消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_MERGER) {
      final mergerElem = V2TimMergerElem(
          title: messagePayload['title'],
          abstractList: formateList(messagePayload['abstractList']),
          isLayersOverLimit: messagePayload['layersOverLimit']);
      formatedMsg['mergerElem'] = mergerElem.toJson();
    }

    // 表情消息
    if (elementType == MessageElemType.V2TIM_ELEM_TYPE_FACE) {
      final faceMessage = V2TimFaceElem(
          index: messagePayload['index'], data: messagePayload['data']);
      formatedMsg['faceElem'] = faceMessage.toJson();
    }

    return formatedMsg;
  }

  // 群组即群名称
  // C2C： 好友备注 => 昵称 =》 userID
  static String getShowName(Map<String, dynamic> itemJS) {
    if (itemJS['remark'] != null && itemJS['remark'] != "") {
      return itemJS['remark'];
    } else if (itemJS['groupProfile'] != null) {
      return itemJS['groupProfile']['name'];
    } else {
      final hasNickName = itemJS["userProfile"]['nick'] != null &&
          itemJS["userProfile"]['nick'] != "";
      return hasNickName
          ? itemJS["userProfile"]['nick']
          : itemJS["userProfile"]['userID'];
    }
  }

  static formateGroupAtInfoList(List groupAtInfoListJs) {
    final groupAtInfoList = [];
    for (var i = 0; i < groupAtInfoListJs.length; i++) {
      final atItem = jsToMap(groupAtInfoListJs[i]);
      final item = {
        "seq": (atItem['messageSequence']).toString(),
        "atType": atItem['atTypeArray'][0] // 这里返回的是一个Array我不懂了
      };
      groupAtInfoList.add(item);
    }
    return groupAtInfoList;
  }

  static formateGroupProfile(Map<String, dynamic> groupProfileJS) async {
    var groupProfile = groupProfileJS;
    if (groupProfileJS['lastMessage'] != null) {
      groupProfile["lastMessage"] =
          await formateLasteMessage(jsToMap(groupProfileJS['lastMessage']));
    }
    if (groupProfileJS['selfInfo'] != null) {
      groupProfile["selfInfo"] = jsToMap(groupProfileJS['selfInfo']);
    }
    if (groupProfileJS['groupCustomField'] != null &&
        groupProfileJS['groupCustomField'].length > 0) {
      groupProfile["groupCustomField"] =
          formateGroupCustomField(groupProfileJS['groupCustomField']);
    }
    return groupProfile;
  }

  static formateProfileCustomField(dynamic profileCustomFieldJS) {
    final groupCustomField = [];
    for (var i = 0; i < profileCustomFieldJS.length; i++) {
      final item = (profileCustomFieldJS[i]);
      groupCustomField.add(item);
    }

    return groupCustomField;
  }

  static formateGroupCustomField(dynamic groupCustomFieldJs) {
    final groupCustomField = [];
    for (var i = 0; i < groupCustomFieldJs.length; i++) {
      final item = jsToMap(groupCustomFieldJs[i]);
      groupCustomField.add(item);
    }

    return groupCustomField;
  }

  static formateUserProfile(Map<String, dynamic> userProfileJS) {
    var userProfile = userProfileJS;
    if (userProfileJS['profileCustomField'] != null &&
        userProfileJS['profileCustomField'].length > 0) {
      userProfile["profileCustomField"] =
          formateProfileCustomField(userProfileJS['profileCustomField']);
    }
    return userProfile;
  }
}
