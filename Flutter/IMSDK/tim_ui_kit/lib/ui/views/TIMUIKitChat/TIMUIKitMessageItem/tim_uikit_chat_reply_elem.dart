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
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_show_panel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_face_elem.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/link_preview_entry.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/models/link_preview_content.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/widgets/link_preview.dart';

class TIMUIKitReplyElem extends StatefulWidget {
  final V2TimMessage message;
  final Function scrollToIndex;
  final bool isShowJump;
  final VoidCallback clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;
  final TUIChatViewModel? chatModel;
  final bool? isShowMessageReaction;
  const TIMUIKitReplyElem({
    Key? key,
    required this.message,
    required this.scrollToIndex,
    this.isShowJump = false,
    required this.clearJump,
    this.fontStyle,
    this.borderRadius,
    this.isShowMessageReaction,
    this.backgroundColor,
    this.textPadding,
    this.chatModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitReplyElemState();
}

class _TIMUIKitReplyElemState extends TIMUIKitState<TIMUIKitReplyElem> {
  TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  MessageRepliedData? repliedMessage;
  V2TimMessage? rawMessage;
  bool isShowJumpState = false;

  MessageRepliedData? _getRepliedMessage() {
    try {
      final CloudCustomData messageCloudCustomData = CloudCustomData.fromJson(
          json.decode(widget.message.cloudCustomData!));
      if (messageCloudCustomData.messageReply != null) {
        final MessageRepliedData repliedMessage =
            MessageRepliedData.fromJson(messageCloudCustomData.messageReply!);
        return repliedMessage;
      }
      return null;
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
          isShowJump: false,
          isShowMessageReaction: false,
          path: message.faceElem!.data ?? "",
          message: message,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(
            isShowMessageReaction: false,
            message: message,
            messageID: message.msgID,
            fileElem: message.fileElem,
            isSelf: isSelf,
            isShowJump: false);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElem(
            message: message, isFrom: "reply", isShowMessageReaction: false);
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(message,
            isFrom: "reply", isShowMessageReaction: false);
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return _defaultRawMessageText(TIM_t("[位置]"), theme);
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIMUIKitMergerElem(
            isShowJump: false,
            isShowMessageReaction: false,
            message: message,
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

  _showJumpColor() {
    int shineAmount = 6;
    setState(() {
      isShowJumpState = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.clearJump();
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
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

  Widget _renderPreviewWidget() {
    // If the link preview info from [localCustomData] is available, use it to render the preview card.
    // Otherwise, it will returns null.
    if (widget.message.localCustomData != null &&
        widget.message.localCustomData!.isNotEmpty) {
      final String localJSON = widget.message.localCustomData!;
      final LinkPreviewModel? localPreviewInfo =
      LinkPreviewModel.fromMap(json.decode(localJSON));
      if (localPreviewInfo != null && !localPreviewInfo.isEmpty()) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child:
          // You can use this default widget [LinkPreviewWidget] to render preview card, or you can use custom widget.
          LinkPreviewWidget(linkPreview: localPreviewInfo),
        );
      } else {
        return Text(widget.message.textElem?.text ?? "",
            softWrap: true,
            style: widget.fontStyle ?? const TextStyle(fontSize: 16));
      }
    } else {
      return Text(widget.message.textElem?.text ?? "",
          softWrap: true,
          style: widget.fontStyle ?? const TextStyle(fontSize: 16));
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    if (widget.isShowJump) {
      Future.delayed(Duration.zero, () {
        _showJumpColor();
      });
    }
    final defaultStyle = (widget.message.isSelf ?? false)
        ? theme.lightPrimaryMaterialColor.shade50
        : theme.weakBackgroundColor;
    final backgroundColor = isShowJumpState
        ? const Color.fromRGBO(245, 166, 35, 1)
        : (widget.backgroundColor ?? defaultStyle);
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
    final textWithLink = LinkPreviewEntry.getHyperlinksText(widget.message);
    return Container(
      padding: widget.textPadding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.borderRadius ?? borderRadius,
      ),
      constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
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
            if (widget.chatModel?.chatConfig.urlPreviewType == null ||
                widget.chatModel?.chatConfig.urlPreviewType ==
                    UrlPreviewType.none)
              Text(widget.message.textElem?.text ?? "",
                  softWrap: true,
                  style: widget.fontStyle ?? const TextStyle(fontSize: 16)),
            if (widget.chatModel?.chatConfig.urlPreviewType != null &&
                widget.chatModel?.chatConfig.urlPreviewType ==
                    UrlPreviewType.onlyHyperlink)
              textWithLink!(
                  style: widget.fontStyle ?? const TextStyle(fontSize: 16)),
            // If the link preview info is available, render the preview card.
            if (widget.chatModel?.chatConfig.urlPreviewType != null &&
                widget.chatModel?.chatConfig.urlPreviewType ==
                    UrlPreviewType.previewCardAndHyperlink)
              _renderPreviewWidget(),
              if(widget.isShowMessageReaction ?? true) TIMUIKitMessageReactionShowPanel(message: widget.message)
          ],
        ),
      ),
    );
  }
}
