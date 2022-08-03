import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/link_preview_entry.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/widgets/link_preview.dart';

import 'TIMUIKitMessageReaction/tim_uikit_message_reaction_show_panel.dart';

class TIMUIKitTextElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isFromSelf;
  final bool isShowJump;
  final VoidCallback clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;
  final TUIChatViewModel chatModel;
  final bool? isShowMessageReaction;
  const TIMUIKitTextElem(
      {Key? key,
      required this.message,
      required this.isFromSelf,
      required this.isShowJump,
      required this.clearJump,
      this.fontStyle,
      this.borderRadius,
      this.isShowMessageReaction,
      this.backgroundColor,
      this.textPadding,
      required this.chatModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextElemState();
}

class _TIMUIKitTextElemState extends TIMUIKitState<TIMUIKitTextElem> {
  bool isShowJumpState = false;

  @override
  void initState() {
    super.initState();
    // get the link preview info
    _getLinkPreview();
  }

  @override
  void didUpdateWidget(TIMUIKitTextElem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.msgID == null && widget.message.msgID != null) {
      _getLinkPreview();
    }
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

  // get the link preview info
  _getLinkPreview() {
    if (widget.chatModel.chatConfig.urlPreviewType !=
        UrlPreviewType.previewCardAndHyperlink) {
      return;
    }
    try{
      if (widget.message.localCustomData != null &&
          widget.message.localCustomData!.isNotEmpty) {
        final String localJSON = widget.message.localCustomData!;
        final LinkPreviewModel? localPreviewInfo =
        LinkPreviewModel.fromMap(json.decode(localJSON));
        // If [localCustomData] is not empty, check if the link preview info exists
        if (localPreviewInfo == null || localPreviewInfo.isEmpty()) {
          // If not exists, get it
          _initLinkPreview();
        }
      } else {
        // It [localCustomData] is empty, get the link info
        _initLinkPreview();
      }
    }catch(e){
      return null;
    }
  }

  _initLinkPreview() async {
    // Get the link preview info from extension, let it update the message UI automatically by providing a [onUpdateMessage].
    // The `onUpdateMessage` can use the `updateMessage()` from the [TIMUIKitChatController] directly.
    LinkPreviewEntry.getFirstLinkPreviewContent(
        message: widget.message,
        onUpdateMessage: () {
          widget.chatModel
              .updateMessageFromController(msgID: widget.message.msgID!);
        });
  }

  Widget? _renderPreviewWidget() {
    // If the link preview info from [localCustomData] is available, use it to render the preview card.
    // Otherwise, it will returns null.
    if (widget.message.localCustomData != null &&
        widget.message.localCustomData!.isNotEmpty) {
      try{
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
          return null;
        }
      }catch(e){
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final textWithLink = LinkPreviewEntry.getHyperlinksText(widget.message);
    final borderRadius = widget.isFromSelf
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
    final defaultStyle = widget.isFromSelf
        ? theme.lightPrimaryMaterialColor.shade50
        : theme.weakBackgroundColor;
    final backgroundColor = isShowJumpState
        ? const Color.fromRGBO(245, 166, 35, 1)
        : (widget.backgroundColor ?? defaultStyle);
    return Container(
      padding: widget.textPadding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.borderRadius ?? borderRadius,
      ),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If the [elemType] is text message, it will not be null here.
          // You can render the widget from extension directly, with a [TextStyle] optionally.
          widget.chatModel.chatConfig.urlPreviewType != UrlPreviewType.none
              ? textWithLink!(
                  style: widget.fontStyle ?? const TextStyle(fontSize: 16))
              : Text(widget.message.textElem?.text ?? "",
                  softWrap: true,
                  style: widget.fontStyle ?? const TextStyle(fontSize: 16)),
          // If the link preview info is available, render the preview card.
          if (_renderPreviewWidget() != null &&
              widget.chatModel.chatConfig.urlPreviewType ==
                  UrlPreviewType.previewCardAndHyperlink)
            _renderPreviewWidget()!,
            if(widget.isShowMessageReaction ?? true)TIMUIKitMessageReactionShowPanel(message: widget.message)
        ],
      ),
    );
  }
}
