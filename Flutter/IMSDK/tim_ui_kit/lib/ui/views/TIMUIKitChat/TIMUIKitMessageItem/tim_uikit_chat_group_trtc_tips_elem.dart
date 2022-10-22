// ignore_for_file: unrelated_type_equality_checks, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';

import '../../../utils/color.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

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
      1: TIM_t("发起通话"),
      2: TIM_t("取消通话"),
      3: TIM_t("接受通话"),
      4: TIM_t("拒绝通话"),
      5: TIM_t("超时未接听"),
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

class _TIMUIKitGroupTrtcTipsElemState
    extends TIMUIKitState<TIMUIKitGroupTrtcTipsElem> {
  final GroupServices groupServices = serviceLocator<GroupServices>();
  // CustomMessage最终展示的内容
  String customMessageShowText = TIM_t("[自定义]");

  @override
  void initState() {
    super.initState();
    final customElem = widget.customMessage?.customElem;
    final groupId = widget.customMessage?.groupID;
    final callingMessage = TIMUIKitGroupTrtcTipsElem.getCallMessage(customElem);
    getShowActionType(callingMessage!, groupId: groupId);
  }

  String getShowName(V2TimGroupMemberFullInfo info) {
    if (info.friendRemark != null && info.friendRemark!.isNotEmpty) {
      return info.friendRemark!;
    } else if (info.nickName != null && info.nickName!.isNotEmpty) {
      return info.nickName!;
    } else if (info.nameCard != null && info.nameCard!.isNotEmpty) {
      return info.nameCard!;
    } else {
      return info.userID;
    }
  }

  getShowNameListFromGroupList(
      List<String> inviteList, List<V2TimGroupMemberFullInfo?> groupInfoList) {
    final showNameList = [];
    for (var info in groupInfoList) {
      final isContains = inviteList.contains(info!.userID);
      if (isContains) {
        showNameList.add(getShowName(info));
      }
    }

    return showNameList;
  }

// 先更新为userID的封装
  handleShowUserIDFrominviteList(
      List<String> inviteeList, String actionTypeText) {
    String nameStr = "";
    for (String showName in inviteeList) {
      nameStr = "$nameStr、$showName";
    }
    nameStr = nameStr.substring(1);
    setState(() {
      customMessageShowText = "$nameStr $actionTypeText";
    });
  }

  // 后更新showNamd的封装
  handleShowNameStringFromList(
      List<dynamic> showNameList, String actionTypeText) {
    if (showNameList.isEmpty) {
      return;
    }
    if (mounted) {
      if (showNameList.length == 1) {
        setState(() {
          customMessageShowText = "${showNameList[0]} $actionTypeText";
        });
      } else {
        String nameStr = "";
        for (String showName in showNameList) {
          nameStr = "$nameStr、$showName";
        }
        nameStr = nameStr.substring(1);
        setState(() {
          customMessageShowText = "$nameStr $actionTypeText";
        });
      }
    }
  }

  // 封装需要节流获取情况用户成员的情况
  handleThrotGetShwoName(
      String groupId, String actionTypeText, CallingMessage callingMessage) {
    handleShowUserIDFrominviteList(callingMessage.inviteeList!, actionTypeText);
    // groupServices.getGroupMembersInfoThrottle(
    //     groupID: groupId,
    //     memberList: callingMessage.inviteeList!,
    //     callBack: (List<V2TimGroupMemberFullInfo?> list) {
    //       List<dynamic> showNameList =
    //           getShowNameListFromGroupList(callingMessage.inviteeList!, list);
    //       // 如果是自己会有为空的情况,需啊自己手动添加一下
    //       if (showNameList.isEmpty) {
    //         final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
    //         final selfShowName = _coreInstance.loginUserInfo?.nickName ??
    //             _coreInstance.loginUserInfo!.userID;
    //         showNameList.add(selfShowName);
    //       }
    //       handleShowNameStringFromList(showNameList, actionTypeText);
    //     });
  }

  getShowActionType(CallingMessage callingMessage, {String? groupId}) async {
    final actionType = callingMessage.actionType!;
    final actionTypeText = TIMUIKitGroupTrtcTipsElem.getActionType(actionType);
    // 1发起通话
    if (actionType == 1 && groupId != null) {
      String nameStr = "";
      groupServices.getGroupMembersInfo(groupID: groupId, memberList: [
        callingMessage.inviter!
      ]).then((V2TimValueCallback<List<V2TimGroupMemberFullInfo>> res) {
        List<V2TimGroupMemberFullInfo>? infoList = res.data ?? [];
        for (var element in infoList) {
          final showName = getShowName(element);
          nameStr = "$nameStr$showName";
        }
        setState(() {
          customMessageShowText = "$nameStr $actionTypeText";
        });
      });
    }
    // 2取消通话
    if (actionType == 2 && groupId != null) {
      setState(() {
        customMessageShowText = actionTypeText;
      });
    }
    // 3为接受
    if (actionType == 3 && groupId != null) {
      handleThrotGetShwoName(groupId, actionTypeText, callingMessage);
    }
    // 4为拒绝
    if (actionType == 4 && groupId != null) {
      List<String> inviteeShowNameList = [];
      V2TimValueCallback<List<V2TimGroupMemberFullInfo>>
          getGroupMembersInfoRes = await TencentImSDKPlugin.v2TIMManager
              .getGroupManager()
              .getGroupMembersInfo(
                groupID: groupId, // 需要获取的群组id
                memberList: callingMessage.inviteeList ?? [], // 需要获取的用户id列表
              );
      if (getGroupMembersInfoRes.code == 0) {
        // 获取成功
        getGroupMembersInfoRes.data?.forEach((element) {
          inviteeShowNameList.add(getShowName(element));
        });
      }
      callingMessage.inviteeList = inviteeShowNameList;
      handleThrotGetShwoName(groupId, actionTypeText, callingMessage);
    }
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
          customMessageShowText = "$nameStr $actionTypeText";
        });
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
    final customElem = widget.customMessage?.customElem;
    final callingMessage = TIMUIKitGroupTrtcTipsElem.getCallMessage(customElem);
    if (callingMessage != null) {
      String showText = TIM_t("[自定义]");
      // 如果是结束消息
      final isCallEnd = isCallEndExist(callingMessage);

      String? option2 = "";
      if (isCallEnd) {
        option2 =
            TIMUIKitGroupTrtcTipsElem.getShowTime(callingMessage.callEnd!);
      }
      showText = isCallEnd
          ? TIM_t_para("通话时间：{{option2}}", "通话时间：$option2")(option2: option2)
          : customMessageShowText;

      return Text(
        showText,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: hexToColor("888888")),
        textAlign: TextAlign.center,
        softWrap: true,
      );
    } else {
      return Text(TIM_t("[自定义]"));
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return MessageUtils.wrapMessageTips(_callElemBuilder(context), theme);
  }
}
