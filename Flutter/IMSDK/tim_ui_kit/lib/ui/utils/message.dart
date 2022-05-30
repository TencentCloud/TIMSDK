// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_im_sdk_plugin/enum/group_change_info_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_tips_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_tips_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/constants/time.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

import '../views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_custom_elem.dart';

class CallingMessage {
  /// 发起邀请方
  String? inviter;

  /// 被邀请方
  List<String>? inviteeList;

  /// videoCall: 语音 audioCall: 视频
  String? callType;

  // 1: 邀请方发起邀请
  // 2: 邀请方取消邀请
  // 3: 被邀请方接受邀请
  // 4: 被邀请方拒绝邀请
  // 5: 邀请超时
  int? actionType;

  /// 邀请ID
  String? inviteID;

  /// 通话时间
  int? timeout;

  /// 通话房间
  int? roomID;

  // 通话时间：秒，大于0代表通话时间
  int? callEnd;
  // 是否是群组通话
  bool? isGroup;

  CallingMessage(
      {this.inviter,
      this.actionType,
      this.inviteID,
      this.inviteeList,
      this.timeout,
      this.roomID,
      this.callType,
      this.callEnd,
      this.isGroup});

  CallingMessage.fromJSON(json) {
    actionType = json["actionType"];
    timeout = json["timeout"];
    inviter = json["inviter"];
    inviteeList = List<String>.from(json["inviteeList"]);
    inviteID = json["inviteID"];
    callType = jsonDecode(json["data"])["cmd"];
    roomID = jsonDecode(json["data"])["room_id"];
    callEnd = jsonDecode(json["data"])["call_end"];
    isGroup = jsonDecode(json["data"])["is_group"];
  }
}

class MessageUtils {
  // 判断CallingData的方式和Trtc的方法一致
  static isCallingData(String data) {
    try {
      Map<String, dynamic> customMap = jsonDecode(data);

      if (customMap.containsKey('businessID') && customMap['businessID'] == 1) {
        return true;
      }
    } catch (e) {
      print("isCallingData json parse error");
      return false;
    }
    return false;
  }

  // 是否是群组TRTC信息
  static isGroupCallingMessage(V2TimMessage message) {
    final isGroup = message.groupID != null;
    final isCustomMessage =
        message.elemType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM;
    if (isCustomMessage) {
      final customElemData = message.customElem?.data ?? "";
      return isCallingData(customElemData) && isGroup;
    }
    return false;
  }

  static String _getGroupChangeType(
      V2TimGroupChangeInfo info, BuildContext context) {
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
        break;
    }

    final String option8 = s;
    return ttBuild.imt_para("{{option8}}为 ", "$option8为 ")(option8: option8) +
        ' $value';
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

    if (friendRemark != null && friendRemark != "") {
      return friendRemark;
    } else if (nameCard != null && nameCard != "") {
      return nameCard;
    } else if (nickName != null && nickName != "") {
      return nickName;
    } else {
      return userID;
    }
  }

  static String groupTipsMessageAbstract(
      V2TimGroupTipsElem groupTipsElem, BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    String displayMessage;
    final operationType = groupTipsElem.type;
    final operationMember = groupTipsElem.opMember;
    final memberList = groupTipsElem.memberList;
    final opUserNickName = _getOpUserNick(operationMember);
    switch (operationType) {
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
        final groupChangeInfoList = groupTipsElem.groupChangeInfoList;
        final String? option7 = opUserNickName ?? "";
        final changedInfoString = groupChangeInfoList!
            .map((e) => _getGroupChangeType(e!, context))
            .join("、");
        displayMessage =
            ttBuild.imt_para("{{option7}}修改", "$option7修改")(option7: option7) +
                changedInfoString;
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT:
        final String? option6 = opUserNickName ?? "";
        displayMessage = ttBuild.imt_para("{{option6}}退出群聊", "$option6退出群聊")(
            option6: option6);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE:
        final option5 =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        final inviteUser = _getOpUserNick(operationMember);
        displayMessage = '$inviteUser' +
            ttBuild.imt_para("邀请{{option5}}加入群组", "邀请$option5加入群组")(
                option5: option5);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_KICKED:
        final option4 =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        final kickUser = _getOpUserNick(operationMember);
        displayMessage = '$kickUser' +
            ttBuild.imt_para("将{{option4}}踢出群组", "将$option4踢出群组")(
                option4: option4);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN:
        final option3 =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        displayMessage = ttBuild.imt_para(
            "用户{{option3}}加入了群聊", "用户$option3加入了群聊")(option3: option3);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE:
        displayMessage = groupTipsElem.memberList!.map((e) {
          final changedMember = groupTipsElem.memberChangeInfoList!
              .firstWhere((element) => element!.userID == e!.userID);
          final isMute = changedMember!.muteTime != 0;
          final option2 = _getMemberNickName(e!);
          final displayMessage =
              isMute ? ttBuild.imt("禁言") : ttBuild.imt("解除禁言");
          return ttBuild.imt_para("{{option2}} 被", "$option2 被")(
                  option2: option2) +
              displayMessage;
        }).join("、");
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
        final adminMember =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        final opMember = _getOpUserNick(operationMember);
        displayMessage = '$opMember' +
            ttBuild.imt_para(
                    "将 {{adminMember}} 设置为管理员", "将 $adminMember 设置为管理员")(
                adminMember: adminMember);
        break;
      case GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
        final adminMember =
            memberList!.map((e) => _getMemberNickName(e!).toString()).join("、");
        final opMember = _getOpUserNick(operationMember);
        displayMessage = '$opMember' +
            ttBuild.imt_para("将 {{adminMember}} 取消管理员", "将 $adminMember 取消管理员")(
                adminMember: adminMember);
        break;
      default:
        final String option2 = operationType.toString();
        displayMessage = ttBuild.imt_para("系统消息 {{option2}}", "系统消息 $option2")(
            option2: option2);
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

  static handleCustomMessage(V2TimMessage message, context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final customElem = message.customElem;
    final callingMessage = TIMUIKitCustomElem.getCallMessage(customElem);
    if (callingMessage != null) {
      // 如果是结束消息
      final isCallEnd = TIMUIKitCustomElem.isCallEndExist(callingMessage);

      final isVoiceCall = callingMessage.callType == 1;

      String? option2 = "";
      if (isCallEnd) {
        option2 = TIMUIKitCustomElem.getShowTime(callingMessage.callEnd!);
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Image.asset(
              isVoiceCall ? "images/voice_call.png" : "images/video_call.png",
              package: 'tim_ui_kit',
              height: 16,
              width: 16,
            ),
          ),
          isCallEnd
              ? Text(ttBuild.imt_para("通话时间：{{option2}}", "通话时间：$option2")(
                  option2: option2))
              : Text(TIMUIKitCustomElem.getActionType(
                  callingMessage.actionType!, ttBuild)),
          // if (isFromSelf)
          //   Padding(
          //     padding: const EdgeInsets.only(left: 4),
          //     child: Image.asset(
          //       isVoiceCall
          //           ? "images/voice_call.png"
          //           : "images/video_call_self.png",
          //       package: 'tim_ui_kit',
          //       height: 16,
          //       width: 16,
          //     ),
          //   ),
        ],
      );
    } else {
      return const Text("[自定义]");
    }
  }

  static Widget wrapMessageTips(Widget child, TUITheme? theme) {
    const borderRadius = BorderRadius.all(
      Radius.circular(5),
    );
    final backgroundColor = theme?.weakBackgroundColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5.0),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
            ),
            child: child)
      ],
    );
  }

  static String getAbstractMessage(V2TimMessage message, BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final msgType = message.elemType;
    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return handleCustomMessage(message, context);
      // ttBuild.imt("[自定义]");
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return ttBuild.imt("[语音]");
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return message.textElem!.text as String;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return ttBuild.imt("[表情]");
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        final String? option2 = message.fileElem!.fileName ?? "";
        return ttBuild.imt_para("[文件] {{option2}}", "[文件] $option2")(
            option2: option2);
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return MessageUtils.groupTipsMessageAbstract(
            message.groupTipsElem!, context);
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
                e?.type == HistoryMessageDartConstant.V2_TIM_IMAGE_TYPES[type],
            orElse: () => null);
      }
    } catch (e) {
      print('getImageFromImgList error ${e.toString()}');
    }
    return img;
  }

  static String getDisplayName(V2TimMessage message) {
    final friendRemark = message.friendRemark ?? "";
    final nameCard = message.nameCard ?? "";
    final nickName = message.nickName ?? "";
    final sender = message.sender ?? "";
    final displayName = friendRemark.isNotEmpty
        ? friendRemark
        : nameCard.isNotEmpty
            ? nameCard
            : nickName.isNotEmpty
                ? nickName
                : sender;
    return displayName.toString();
  }

  static Future<V2TimValueCallback<V2TimMessage>?> handleMessageError(
      Future<V2TimValueCallback<V2TimMessage>?> fun,
      BuildContext context) async {
    final res = await fun;
    return handleMessageErrorCode(res, context);
  }

  static V2TimValueCallback<V2TimMessage>? handleMessageErrorCode(
      V2TimValueCallback<V2TimMessage>? sendMsgRes, BuildContext context) {
    if (sendMsgRes == null) return null;
    int code = sendMsgRes.code;
    String desc = sendMsgRes.desc;
    final I18nUtils ttBuild = I18nUtils(context);
    if (code == 10004) {
      if (desc.contains("not support @all")) {
        Fluttertoast.showToast(
            msg: ttBuild.imt("当前群组不支持@全体成员"), gravity: ToastGravity.CENTER);
      }
    }
    if (code == 80001) {
      Fluttertoast.showToast(
          msg: ttBuild.imt("发言中有非法语句"),
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2);
    }

    return sendMsgRes;
  }
}
