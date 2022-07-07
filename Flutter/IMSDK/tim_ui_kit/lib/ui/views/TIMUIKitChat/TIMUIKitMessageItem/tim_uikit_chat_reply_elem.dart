// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_face_elem.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/link_preview_entry.dart';

class CloudCustomData {
  late Map<String, dynamic> messageReply;
  late String messageAbstract;
  late String messageSender;
  late String messageID;

  CloudCustomData.fromJson(json) {
    messageReply = json["messageReply"];
    messageAbstract = messageReply["messageAbstract"];
    messageSender = messageReply["messageSender"] ?? "";
    messageID = messageReply["messageID"];
  }
}

class TIMUIKitReplyElem extends StatefulWidget {
  final V2TimMessage message;
  final Function scrollToIndex;
  final bool isShowJump;
  final VoidCallback clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;

  const TIMUIKitReplyElem({
    Key? key,
    required this.message,
    required this.scrollToIndex,
    this.isShowJump = false,
    required this.clearJump,
    this.fontStyle,
    this.borderRadius,
    this.backgroundColor,
    this.textPadding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitReplyElemState();
}

class _TIMUIKitReplyElemState extends TIMUIKitState<TIMUIKitReplyElem> {
  TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  CloudCustomData? repliedMessage;
  V2TimMessage? rawMessage;
  Color backgroundColorNormal = const Color.fromRGBO(236, 236, 236, 1);
  Color backgroundColorJump = const Color.fromRGBO(245, 166, 35, 1);
  Color backgroundColor = const Color.fromRGBO(236, 236, 236, 1);

  CloudCustomData? _getRepliedMessage() {
    try {
      final messageCloudCustomData =
          json.decode(widget.message.cloudCustomData!);
      final repliedMessage = CloudCustomData.fromJson(messageCloudCustomData);
      return repliedMessage;
    } catch (error) {
      return null;
    }
  }

  _getMessageByMessageID() async {
    final cloudCustomData = _getRepliedMessage();
    if (cloudCustomData != null) {
      final messageID = cloudCustomData.messageID;
      final message = await model.findMessage(messageID);
      if (message != null) {
        setState(() {
          rawMessage = message;
        });
      }
    }
    setState(() {
      repliedMessage = cloudCustomData;
    });
  }

  Widget _defaultRawMessageText(String text, TUITheme? theme) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            color: theme?.weakTextColor,
            fontWeight: FontWeight.w400));
  }

  _rawMessageBuilder(V2TimMessage? message, TUITheme? theme) {
    if (message == null) {
      return _defaultRawMessageText(repliedMessage!.messageAbstract, theme);
    }
    final messageType = message.elemType;
    final isSelf = message.isSelf ?? false;
    if (model.abstractMessageBuilder != null) {
      return _defaultRawMessageText(
        model.abstractMessageBuilder!(message),
        theme,
      );
    }
    switch (messageType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return _defaultRawMessageText(TIM_t("[自定义]"), theme);
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return _defaultRawMessageText(TIM_t("[语音消息]"), theme);
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return _defaultRawMessageText(message.textElem?.text ?? "", theme);
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return TIMUIKitFaceElem(
          path: message.faceElem!.data ?? "",
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(
            messageID: message.msgID,
            fileElem: message.fileElem,
            isSelf: isSelf);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElem(message: message, isFrom: "reply");
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(message, isFrom: "reply");
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return _defaultRawMessageText(TIM_t("[位置]"), theme);
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIMUIKitMergerElem(
            mergerElem: message.mergerElem!,
            messageID: message.msgID ?? "",
            isSelf: isSelf);
      default:
        return _defaultRawMessageText(TIM_t("[未知消息]"), theme);
    }
  }

  @override
  void initState() {
    _getMessageByMessageID();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TIMUIKitReplyElem oldWidget) {
    WidgetsBinding.instance?.addPostFrameCallback((mag) {
      super.didUpdateWidget(oldWidget);
      _getMessageByMessageID();
    });
  }

  void _showJumpColor() {
    int shineAmount = 10;
    setState(() {
      backgroundColor = backgroundColorJump;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.clearJump();
    });
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          backgroundColor =
              shineAmount.isOdd ? backgroundColorJump : backgroundColorNormal;
        });
      }
      if (shineAmount == 0 || !mounted) {
        timer.cancel();
      }
      shineAmount--;
    });
  }

  void _jumpToRawMsg() {
    if (rawMessage?.timestamp != null) {
      widget.scrollToIndex(rawMessage);
    } else {
      onTIMCallback(TIMCallback(
          type: TIMCallbackType.INFO,
          infoRecommendText: TIM_t("无法定位到原消息"),
          infoCode: 6660401));
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final isSelf = widget.message.isSelf ?? false;
    backgroundColorNormal = widget.backgroundColor ??
        (isSelf
            ? theme.lightPrimaryMaterialColor.shade50
            : theme.weakBackgroundColor ??
                const Color.fromRGBO(236, 236, 236, 1));
    backgroundColor = backgroundColorNormal;
    if (repliedMessage == null) {
      return Container();
    }
    final isFromSelf = widget.message.isSelf ?? false;

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
    if (widget.isShowJump) {
      Future.delayed(Duration.zero, () {
        _showJumpColor();
      });
    }
    final textWithLink = LinkPreviewEntry.getHyperlinksText(widget.message);
    return Container(
      padding: widget.textPadding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.borderRadius ?? borderRadius,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      child: GestureDetector(
        onTap: _jumpToRawMsg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // 这里是引用的部分
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              constraints: const BoxConstraints(minWidth: 120),
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(68, 68, 68, 0.05),
                  border: Border(
                      left: BorderSide(
                          color: Color.fromRGBO(68, 68, 68, 0.1), width: 2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${repliedMessage!.messageSender}:",
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.weakTextColor,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  _rawMessageBuilder(rawMessage, theme)
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            textWithLink!(
              style: widget.fontStyle ??
                  const TextStyle(
                    fontSize: 16,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
