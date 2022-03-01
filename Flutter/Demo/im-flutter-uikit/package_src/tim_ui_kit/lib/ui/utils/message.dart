import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/enum/group_change_info_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_tips_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_tips_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/constants/time.dart';

import '../../i18n/i18n_utils.dart';

class MessageUtils {
  static String _getGroupChangeType(V2TimGroupChangeInfo info, BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    int? type = info.type;
    var value = info.value;
    String s = '';
    switch (type) {
      case GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM:
        s = ttBuild.imt("自定义字段");
        value = '';
        break;
      case GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL:
        s = ttBuild.imt("群头像");
        value = '';
        break;
      case GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION:
        s = ttBuild.imt("群简介");
        break;
      case GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME:
        s = ttBuild.imt("群名称");
        break;
      case GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
        s = ttBuild.imt("群通知");
        break;
      case GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
        s = ttBuild.imt("群主");
        value = '';
        break;
    }

    return ttBuild.imt_para("{{s}}为", "${s}为")(s: s) + '<${value}>';
  }

  static String? _getOpUserNick(V2TimGroupMemberInfo opUser) {
    return opUser.friendRemark == null || opUser.friendRemark == ''
        ? opUser.nickName == null || opUser.nickName == ''
            ? opUser.userID
            : opUser.nickName
        : opUser.friendRemark;
  }

  static String? _getMemberNickName(V2TimGroupMemberInfo e) {
    final friendRemark = e.friendRemark;
    final nameCard = e.nameCard;
    final nickName = e.nickName;
    final userID = e.userID;
    return friendRemark ?? nameCard ?? nickName ?? userID;
  }

  static String groupTipsMessageAbstract(V2TimGroupTipsElem groupTipsElem, BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    String displayMessage;
    final operationType = groupTipsElem.type;
    final operationMember = groupTipsElem.opMember;
    final memberList = groupTipsElem.memberList;
    final opUserNickName = _getOpUserNick(operationMember);
    switch (operationType) {
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
        final groupChangeInfoList = groupTipsElem.groupChangeInfoList;
        final changedInfoString =
            groupChangeInfoList!.map((e) => _getGroupChangeType(e!, context)).join("、");
        displayMessage =
            ttBuild.imt_para("<{{opUserNickName}}>修改", "<${opUserNickName}>修改")(opUserNickName: opUserNickName) + changedInfoString;
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT:
        displayMessage = ttBuild.imt_para("<{{opUserNickName}}>退出群聊", "<${opUserNickName}>退出群聊")(opUserNickName: opUserNickName);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE:
        final invitedMemberString =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        final inviteUser = _getOpUserNick(operationMember);
        displayMessage =
            '<${inviteUser}>' + ttBuild.imt_para("邀请<{{invitedMemberString}}>加入群组", "邀请<${invitedMemberString}>加入群组")(invitedMemberString: invitedMemberString);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_KICKED:
        final invitedMemberString =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        final kickUser = _getOpUserNick(operationMember);
        displayMessage =
            '<${kickUser}>' + ttBuild.imt_para("将<{{invitedMemberString}}>踢出群组", "将<${invitedMemberString}>踢出群组")(invitedMemberString: invitedMemberString);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN:
        final joinedMemberString =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        displayMessage = ttBuild.imt_para("用户<{{joinedMemberString}}>加入了群聊", "用户<${joinedMemberString}>加入了群聊")(joinedMemberString: joinedMemberString);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE:
        displayMessage = groupTipsElem.memberList!.map((e) {
          final changedMember = groupTipsElem.memberChangeInfoList!
              .firstWhere((element) => element!.userID == e!.userID);
          final isMute = changedMember!.muteTime != 0;
          final userName = _getMemberNickName(e!);
          final displayMessage = isMute ? ttBuild.imt("禁言") : ttBuild.imt("解除禁言");
          return ttBuild.imt_para("{{userName}} 被", "${userName} 被")(userName: userName) + displayMessage;
        }).join("、");
        break;
      default:
        displayMessage = ttBuild.imt_para("系统消息{{operationType}}", "系统消息${operationType}")(operationType: operationType);
        break;
    }
    return displayMessage;
  }

  static String formatVideoTime(int time) {
    List<int> times = [];
    if (time <= 0) return '0:01';
    if (time >= TimeConst.DAY_SEC) return '1d+';
    for (int idx = 0; idx < TimeConst.SEC_SERIES.length; idx++) {
      int sec = TimeConst.SEC_SERIES[idx];
      if (time >= sec) {
        times.add((time / sec).floor());
        time = time % sec;
      } else if (idx > 0) {
        times.add(0);
      }
    }
    times.add(time);
    String formatTime = times[0].toString();
    for (int idx = 1; idx < times.length; idx++) {
      if (times[idx] < 10) {
        formatTime += ':0${times[idx].toString()}';
      } else {
        formatTime += ':${times[idx].toString()}';
      }
    }
    return formatTime;
  }

  static String getAbstractMessage(V2TimMessage message, BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final msgType = message.elemType;
    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return ttBuild.imt("[自定义]");
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return ttBuild.imt("[语音]");
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return message.textElem!.text as String;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return ttBuild.imt("[表情]");
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        final fileName = message.fileElem!.fileName;
        return ttBuild.imt_para("[文件] {{fileName}}", "[文件] ${fileName}")(fileName: fileName);
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return MessageUtils.groupTipsMessageAbstract(message.groupTipsElem!, context);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return ttBuild.imt("[图片]");
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return ttBuild.imt("[视频]");
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return ttBuild.imt("[位置]");
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return ttBuild.imt("[聊天记录]");
      default:
        return ttBuild.imt("未知消息");
    }
  }

  static V2TimImage? getImageFromImgList(
      List<V2TimImage?>? list, List<String> order) {
    V2TimImage? img;
    try {
      for (String type in order) {
        img = list?.firstWhere(
            (e) =>
                e!.type == HistoryMessageDartConstant.V2_TIM_IMAGE_TYPES[type],
            orElse: () => null);
      }
    } catch (e) {
      print('getImageFromImgList error ${e.toString()}');
    }
    return img;
  }

  static String getDisplayName(V2TimMessage message) {
    final friendRemark = message.friendRemark;
    final nameCard = message.nameCard;
    final nickName = message.nickName;
    final sender = message.sender;
    final displayName = friendRemark ?? nameCard ?? nickName ?? sender;
    return displayName.toString();
  }
}
