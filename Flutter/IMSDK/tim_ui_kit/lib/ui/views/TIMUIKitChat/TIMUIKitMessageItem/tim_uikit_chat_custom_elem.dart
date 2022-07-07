// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';

import 'package:tim_ui_kit/ui/utils/message.dart';

class TIMUIKitCustomElem extends TIMUIKitStatelessWidget {
  final V2TimCustomElem? customElem;
  final bool isFromSelf;
  final TextStyle? messageFontStyle;
  final BorderRadius? messageBorderRadius;
  final Color? messageBackgroundColor;
  final EdgeInsetsGeometry? textPadding;

  TIMUIKitCustomElem({
    Key? key,
    this.customElem,
    this.isFromSelf = false,
    this.messageFontStyle,
    this.messageBorderRadius,
    this.messageBackgroundColor,
    this.textPadding,
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

  static String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  static getShowTime(int seconds) {
    int secondsShow = seconds % 60;
    int minutsShow = seconds ~/ 60;
    return "${twoDigits(minutsShow)}:${twoDigits(secondsShow)}";
  }

  Widget _callElemBuilder() {
    final callingMessage = getCallMessage(customElem);

    if (callingMessage != null) {
      // 如果是结束消息
      final isCallEnd = isCallEndExist(callingMessage);

      final isVoiceCall = callingMessage.callType == 1;

      String? option2 = "";
      if (isCallEnd) {
        option2 = getShowTime(callingMessage.callEnd!);
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFromSelf)
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
              ? Text(TIM_t_para("通话时间：{{option2}}", "通话时间：$option2")(
                  option2: option2))
              : Text(
                  getActionType(callingMessage.actionType!),
                  style: messageFontStyle,
                ),
          if (isFromSelf)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.asset(
                isVoiceCall
                    ? "images/voice_call.png"
                    : "images/video_call_self.png",
                package: 'tim_ui_kit',
                height: 16,
                width: 16,
              ),
            ),
        ],
      );
    } else {
      return const Text("[自定义]");
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final borderRadius = isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    final backgroundColor = isFromSelf
        ? theme.lightPrimaryMaterialColor.shade50
        : theme.weakBackgroundColor;
    return Container(
      padding: textPadding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: messageBackgroundColor ?? backgroundColor,
        borderRadius: messageBorderRadius ?? borderRadius,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      child: _callElemBuilder(),
    );
  }
}
