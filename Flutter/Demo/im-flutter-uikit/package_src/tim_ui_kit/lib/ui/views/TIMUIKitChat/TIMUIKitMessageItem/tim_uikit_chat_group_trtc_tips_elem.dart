import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_custom_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/shared_theme.dart';

import '../../../../i18n/i18n_utils.dart';

class TIMUIKitGroupTrtcTipsElem extends StatefulWidget {
  final V2TimMessage? customMessage;

  const TIMUIKitGroupTrtcTipsElem({
    Key? key,
    this.customMessage,
  }) : super(key: key);

  static CallingMessage? getCallMessage(V2TimCustomElem? customElem) {
    try {
      if (customElem?.data != null) {
        final customMessage = jsonDecode(customElem!.data!);
        return CallingMessage.fromJSON(customMessage);
      }
      return null;
    } catch (err) {
      return null;
    }
  }

  static String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  static String getActionType(int actionType) {
    final actionMessage = {
      1: "发起通话",
      2: "取消通话",
      3: "接受通话",
      4: "拒绝通话",
      5: "超时未接听",
    };
    return actionMessage[actionType] ?? "";
  }

  static isCallEndExist(CallingMessage callMsg) {
    int? callEnd = callMsg.callEnd;
    int? actionType = callMsg.actionType;
    if (actionType == 2) return false;
    return callEnd == null
        ? false
        : callEnd > 0
            ? true
            : false;
  }

  static getShowTime(int seconds) {
    int secondsShow = seconds % 60;
    int minutsShow = seconds ~/ 60;
    return "${twoDigits(minutsShow)}:${twoDigits(secondsShow)}";
  }

  @override
  State<StatefulWidget> createState() => _TIMUIKitGroupTrtcTipsElemState();
}

class _TIMUIKitGroupTrtcTipsElemState extends State<TIMUIKitGroupTrtcTipsElem> {
  final GroupServices groupServices = serviceLocator<GroupServices>();
  // CustomMessage最终展示的内容
  String customMessageShowText = "[自定义]";

  @override
  void initState() {
    super.initState();
    final customElem = widget.customMessage?.customElem;
    final groupId = widget.customMessage?.groupID;
    final callingMessage = TIMUIKitGroupTrtcTipsElem.getCallMessage(customElem);
    getShowActionType(callingMessage!, groupId: groupId);
  }

  String getShowName(V2TimGroupMemberFullInfo info) {
    return info.friendRemark ?? info.nickName ?? info.nameCard ?? info.userID;
  }

  getShowActionType(CallingMessage callingMessage, {String? groupId}) {
    final actionType = callingMessage.actionType!;
    final actionTypeText = TIMUIKitGroupTrtcTipsElem.getActionType(actionType);
    // 5 为超时
    if (actionType == 5 && groupId != null) {
      String nameStr = "";
      groupServices
          .getGroupMembersInfo(
              groupID: groupId, memberList: callingMessage.inviteeList!)
          .then((V2TimValueCallback<List<V2TimGroupMemberFullInfo>> res) {
        List<V2TimGroupMemberFullInfo>? infoList = res.data ?? [];
        for (var element in infoList) {
          final showName = getShowName(element);
          nameStr = "$nameStr、$showName";
        }
        nameStr = nameStr.substring(1);

        setState(() {
          customMessageShowText = "$nameStr$actionTypeText";
        });
      });
    } else {
      setState(() {
        customMessageShowText = actionTypeText;
      });
    }

    // return TIMUIKitCustomElem.getActionType(actionType);
  }

  static isCallEndExist(CallingMessage callMsg) {
    int? callEnd = callMsg.callEnd;
    int? actionType = callMsg.actionType;
    if (actionType == 2) return false;
    return callEnd == null
        ? false
        : callEnd > 0
            ? true
            : false;
  }

  Widget _callElemBuilder(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final customElem = widget.customMessage?.customElem;
    final callingMessage = TIMUIKitGroupTrtcTipsElem.getCallMessage(customElem);

    if (callingMessage != null) {
      String showText = "[自定义]";
      // 如果是结束消息
      final isCallEnd = isCallEndExist(callingMessage);

      final isVoiceCall = callingMessage.callType == 1;

      String? callTime = "";
      if (isCallEnd) {
        callTime =
            TIMUIKitGroupTrtcTipsElem.getShowTime(callingMessage.callEnd!);
      }
      showText = isCallEnd
          ? ttBuild.imt_para("通话时间：{{callTime}}", "通话时间：$callTime")(
              callTime: callTime)
          : customMessageShowText;

      return Text(
        showText,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
        softWrap: true,
      );
    } else {
      return const Text("[自定义]");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;

    return MessageUtils.wrapMessageTips(_callElemBuilder(context), theme);
  }
}
