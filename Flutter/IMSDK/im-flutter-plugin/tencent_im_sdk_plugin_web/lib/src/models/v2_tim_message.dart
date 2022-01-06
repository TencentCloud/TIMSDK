import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_change_info_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/group_tips_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_custom_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_face_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_file_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_tips_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_image.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_image_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_location_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_merger_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_text_elem.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_video_elem.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/group_tips_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_group_create.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_message_status.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_notice_message_listiner.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/message_type.dart';

class V2TIMMessage {
  static final V2TIMManager _v2timManager = V2TIMManager();

  static String getReciveMessageType(Map<String, dynamic> messageItem) {
    final convType = messageItem['conversationType'];
    final messageType = messageItem['type'];
    if (convType == ConversationTypeWeb.CONV_C2C &&
        messageType == MsgType.MSG_TEXT) {
      return 'onRecvC2CTextMessage';
    }

    if (convType == ConversationTypeWeb.CONV_GROUP &&
        messageType == MsgType.MSG_TEXT) {
      return 'onRecvGroupTextMessage';
    }

    if (convType == ConversationTypeWeb.CONV_C2C &&
        messageType == MsgType.MSG_CUSTOM) {
      return 'onRecvC2CCustomMessage';
    }

    if (convType == ConversationTypeWeb.CONV_GROUP &&
        messageType == MsgType.MSG_CUSTOM) {
      return 'onRecvGroupCustomMessage';
    }

    return '';
  }

  static Future<Map<String, dynamic>> convertMessageFromWebToDart(
      jsMessage) async {
    final message = jsToMap(jsMessage);
    final elementType = MsgType.convertMsgType(message['type']);
    final formatedMsg = <String, dynamic>{
      "msgID": message["ID"] ?? '',
      "timestamp": message["time"],
      "progress": 100,
      "sender": message["from"] ?? message["fromAccount"] ?? '',
      "nickName": message["nick"] ?? '',
      "friendRemark": "",
      "faceUrl": message["avatar"] ?? '',
      "nameCard": message["nameCard"] ?? '',
      "groupID": message["conversationType"] == "GROUP" ? message["to"] : null,
      "userID": message["conversationType"] == "C2C" ? message["to"] : null,
      "status": MessageStatusWeb.convertMessageStatus(message),
      "elemType": elementType,
      "localCustomData": "",
      "localCustomInt": 0,
      "cloudCustomData": message["cloudCustomData"] ?? '',
      "isSelf": message["flow"] == "out" ? true : false,
      "isRead": message["isRead"] ?? false,
      "isPeerRead": message["isPeerRead"] ?? false,
      "priority": MessagePriorityWeb.convertMsgPriority(message["priority"]),
      "groupAtUserList": message["atUserList"],
      "seq": message["sequence"].toString(),
      "random": message["random"],
      "isExcludedFromUnreadCount": false,
      "messageFromWeb": stringify(jsMessage)
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
      final groupTipsElement = await convertGroupTipsMessage(message);
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

  static _convertGroupTipsProfileUpdated(Map<String, dynamic> message) {
    final List<V2TimGroupChangeInfo> groupInfoChangeList =
        List.empty(growable: true);
    final Map<String, dynamic> newGroupProfile =
        jsToMap(jsToMap(message['payload'])['newGroupProfile']);
    for (var key in newGroupProfile.keys) {
      var value = newGroupProfile[key];
      var type;
      if (key == 'groupName') {
        type = GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME;
      }

      if (key == 'introduction') {
        type = GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION;
      }

      if (key == 'avatar') {
        type = GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL;
      }

      if (key == 'notification') {
        type = GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION;
      }

      if (key == 'groupCustomField') {
        type = GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM;
        value = V2TimGroupCreate.convertGroupCustomInfoFromWebToDart(value);
      }

      if (type != null) {
        groupInfoChangeList.add(V2TimGroupChangeInfo(type: type, value: value));
      }
    }

    return groupInfoChangeList;
  }

  static Future<List<V2TimGroupMemberInfo>> _getGroupMemberInfo(
      Map<String, dynamic> message) async {
    final userIDList = jsToMap(message['payload'])['userIDList'];
    final userInFoRes =
        await _v2timManager.getUsersInfo({'userIDList': userIDList});

    final List<V2TimUserFullInfo>? userInfoList = userInFoRes.data;
    final List<V2TimGroupMemberInfo> memberList = List.empty(growable: true);
    for (var e in userInfoList!) {
      memberList.add(V2TimGroupMemberInfo(
          faceUrl: e.faceUrl,
          userID: e.userID,
          nickName: e.nickName,
          friendRemark: '',
          nameCard: ''));
    }
    return memberList;
  }

  static Future<V2TimGroupMemberInfo> _getMemberInfo(String userID) async {
    final userInfoRes = await _v2timManager.getUsersInfo({
      'userIDList': [userID]
    });

    final List<V2TimUserFullInfo>? data = userInfoRes.data;
    final userInfoDetails = data!.first;
    final member = V2TimGroupMemberInfo(
        faceUrl: userInfoDetails.faceUrl,
        userID: userInfoDetails.userID,
        nickName: userInfoDetails.nickName,
        friendRemark: '',
        nameCard: '');
    return member;
  }

  static List<V2TimGroupMemberChangeInfo> _convertGroupMemberInfoChanged(
      Map<String, dynamic> message) {
    final List memberList = jsToMap(message['payload'])['memberList'];
    final memberChangeInfo = memberList
        .map((e) =>
            V2TimGroupMemberChangeInfo(userID: e.userID, muteTime: e.muteTime))
        .toList();
    return memberChangeInfo;
  }

  static Future<NoticeMessageListenner?> convertGroupNoticeMessage(
      Map<String, dynamic> message) async {
    final messagePayload = jsToMap(message['payload']);
    final operationType = messagePayload['operationType'];
    final optId = messagePayload['operatorID'];
    final member = await _getMemberInfo(optId);

    // 有用户申请加入群
    if (operationType == 1) {
      return NoticeMessageListenner(
          listennerName: 'onReceiveJoinApplication',
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          opUser: member,
          opReason: messagePayload['handleMessage']);
    }

    // 申请加群被同意或拒绝
    if (operationType == 2 || operationType == 3) {
      return NoticeMessageListenner(
          listennerName: 'onApplicationProcessed',
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          opUser: member,
          isAgreeJoin: operationType == 2,
          opReason: messagePayload['handleMessage']);
    }

    // 群解散
    if (operationType == 5) {
      return NoticeMessageListenner(
          listennerName: 'onGroupDismissed',
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          opUser: member);
    }
    // 创建群组
    if (operationType == 6) {
      return NoticeMessageListenner(
          listennerName: 'onGroupCreated',
          opUser: member,
          groupID: jsToMap(messagePayload['groupProfile'])['groupID']);
    }

    // 群回收
    if (operationType == 11) {
      return NoticeMessageListenner(
          listennerName: 'onGroupRecycled',
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          opUser: member);
    }

    // 用户自定义通知
    if (operationType == 255) {
      return NoticeMessageListenner(
          opUser: member,
          listennerName: 'onReceiveRESTCustomData',
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          customData: messagePayload['userDefinedField']);
    }
  }

  static Future<V2TimGroupTipsElem?> convertGroupTipsMessage(
      Map<String, dynamic> message) async {
    final messagePayload = jsToMap(message['payload']);
    final operationType = messagePayload['operationType'];
    final optId = messagePayload['operatorID'];

    final opMember = await _getMemberInfo(optId);

    // 群资料变更
    if (operationType == GroupTips.GRP_TIP_GRP_PROFILE_UPDATED) {
      final groupInfoChangeList = _convertGroupTipsProfileUpdated(message);
      return V2TimGroupTipsElem(
          memberCount: 0,
          memberList: [],
          memberChangeInfoList: [],
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: groupInfoChangeList,
          type: GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE,
          opMember: opMember);
    }

    // 踢人出群
    if (operationType == GroupTips.GRP_TIP_MBR_KICKED_OUT) {
      final List<V2TimGroupMemberInfo> memberList =
          await _getGroupMemberInfo(message);
      return V2TimGroupTipsElem(
          memberCount: messagePayload['memberCount'],
          memberList: memberList,
          memberChangeInfoList: [],
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: [],
          type: GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_KICKED,
          opMember: opMember);
    }

    //成员加群
    if (operationType == GroupTips.GRP_TIP_MBR_JOIN) {
      final isJoinGroup =
          messagePayload['operatorID'] == messagePayload['userIDList'][0];
      final List<V2TimGroupMemberInfo> memberList =
          await _getGroupMemberInfo(message);
      return V2TimGroupTipsElem(
          memberCount: messagePayload['memberCount'],
          memberList: memberList,
          memberChangeInfoList: [],
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: [],
          type: isJoinGroup
              ? GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN
              : GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE,
          opMember: opMember);
    }

    //成员退群
    if (operationType == GroupTips.GRP_TIP_MBR_QUIT) {
      final List<V2TimGroupMemberInfo> memberList =
          await _getGroupMemberInfo(message);
      return V2TimGroupTipsElem(
          memberCount: messagePayload['memberCount'],
          memberList: memberList,
          memberChangeInfoList: [],
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: [],
          type: GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT,
          opMember: opMember);
    }

    //指定管理员身份
    if (operationType == GroupTips.GRP_TIP_MBR_SET_ADMIN) {
      final List<V2TimGroupMemberInfo> memberList =
          await _getGroupMemberInfo(message);
      return V2TimGroupTipsElem(
          memberCount: messagePayload['memberCount'],
          memberList: memberList,
          memberChangeInfoList: [],
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: [],
          type: GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN,
          opMember: opMember);
    }

    // 撤销管理员身份
    if (operationType == GroupTips.GRP_TIP_MBR_SET_ADMIN) {
      final List<V2TimGroupMemberInfo> memberList =
          await _getGroupMemberInfo(message);
      return V2TimGroupTipsElem(
          memberCount: messagePayload['memberCount'],
          memberList: memberList,
          memberChangeInfoList: [],
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: [],
          type: GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN,
          opMember: opMember);
    }

    // 群成员资料变更，例如：群成员被禁言
    if (operationType == GroupTips.GRP_TIP_MBR_PROFILE_UPDATED) {
      final List<V2TimGroupMemberChangeInfo> groupMemberChangeInfoList =
          _convertGroupMemberInfoChanged(message);
      return V2TimGroupTipsElem(
          memberCount: messagePayload['memberCount'],
          memberList: [],
          memberChangeInfoList: groupMemberChangeInfoList,
          groupID: jsToMap(messagePayload['groupProfile'])['groupID'],
          groupChangeInfoList: [],
          type: GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE,
          opMember: opMember);
    }
  }
}
