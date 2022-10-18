// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';

import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_custom_elem.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class TIMUIKitLastMsg extends TIMUIKitStatelessWidget {
  final V2TimMessage? lastMsg;
  final List<V2TimGroupAtInfo?> groupAtInfoList;
  final BuildContext context;
  TIMUIKitLastMsg(
      {Key? key,
      this.lastMsg,
      required this.groupAtInfoList,
      required this.context})
      : super(key: key);

  String _getMsgElem() {
    final isRevokedMessage = lastMsg!.status == 6;
    if (isRevokedMessage) {
      final isSelf = lastMsg!.isSelf ?? false;
      final option1 =
          isSelf ? TIM_t("您") : lastMsg!.nickName ?? lastMsg?.sender;
      return TIM_t_para("{{option1}}撤回了一条消息", "$option1撤回了一条消息")(
          option1: option1);
    }
    return _getLastMsgShowText(lastMsg, context);
  }

  static LinkMessage? getLinkMessage(V2TimCustomElem? customElem) {
    try {
      if (customElem?.data != null) {
        final customMessage = jsonDecode(customElem!.data!);
        return LinkMessage.fromJSON(customMessage);
      }
      return null;
    } catch (err) {
      return null;
    }
  }

  static String handleCustomMessage(V2TimMessage message) {
    final customElem = message.customElem;
    final callingMessage = TIMUIKitCustomElem.getCallMessage(customElem);
    final linkMessage = getLinkMessage(customElem);
    String customLastMsgShow = TIM_t("[自定义]");
    if (customElem?.data == "group_create") {
      customLastMsgShow = TIM_t("群聊创建成功！");
    }
    if (callingMessage != null) {
      // 如果是结束消息
      final isCallEnd = TIMUIKitCustomElem.isCallEndExist(callingMessage);

      final isVoiceCall = callingMessage.callType == 1;

      String? callTime = "";

      if (isCallEnd) {
        callTime = TIMUIKitCustomElem.getShowTime(callingMessage.callEnd!);
      }

      final option3 = callTime;
      customLastMsgShow = isCallEnd
          ? TIM_t_para("通话时间：{{option3}}", "通话时间：$option3")(option3: option3)
          : TIMUIKitCustomElem.getActionType(callingMessage.actionType!);

      final option1 = customLastMsgShow;
      final option2 = customLastMsgShow;
      customLastMsgShow = isVoiceCall
          ? TIM_t_para("[语音通话]：{{option1}}", "[语音通话]：$option1")(
              option1: option1)
          : TIM_t_para("[视频通话]：{{option2}}", "[视频通话]：$option2")(
              option2: option2);
    } else if (linkMessage != null && linkMessage.text != null) {
      customLastMsgShow = linkMessage.text!;
    }
    return customLastMsgShow;
  }

  String _getLastMsgShowText(V2TimMessage? message, BuildContext context) {
    final msgType = message!.elemType;
    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return handleCustomMessage(message);
      // TIM_t("[自定义]");
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return TIM_t("[语音]");
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return lastMsg?.textElem?.text ?? "";
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return TIM_t("[表情]");
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        final option1 = lastMsg!.fileElem!.fileName;
        return TIM_t_para("[文件] {{option1}}", "[文件] $option1")(
            option1: option1);
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return MessageUtils.groupTipsMessageAbstract(lastMsg!.groupTipsElem!);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIM_t("[图片]");
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIM_t("[视频]");
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return TIM_t("[位置]");
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIM_t("[聊天记录]");
      default:
        return TIM_t("未知消息");
    }
  }

  Icon? _getIconByMsgStatus(BuildContext context) {
    final msgStatus = lastMsg!.status;
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    if (msgStatus == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL) {
      return Icon(Icons.error, color: theme.cautionColor, size: 16);
    }
    if (msgStatus == MessageStatus.V2TIM_MSG_STATUS_SENDING) {
      return Icon(Icons.arrow_back, color: theme.weakTextColor, size: 16);
    }
    return null;
  }

  String _getAtMessage() {
    String msg = "";
    for (var item in groupAtInfoList) {
      if (item!.atType == 1) {
        msg = TIM_t("[有人@我] ");
      } else {
        msg = TIM_t("[@所有人] ");
      }
    }
    return msg;
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final icon = _getIconByMsgStatus(context);
    return Row(children: [
      if (icon != null)
        Container(
          margin: const EdgeInsets.only(right: 2),
          child: icon,
        ),
      if (groupAtInfoList.isNotEmpty)
        Text(_getAtMessage(),
            style: TextStyle(color: theme.cautionColor, fontSize: 14)),
      Expanded(
          child: Text(
        _getMsgElem(),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(height: 1, color: theme.weakTextColor, fontSize: 14),
      )),
    ]);
  }
}
