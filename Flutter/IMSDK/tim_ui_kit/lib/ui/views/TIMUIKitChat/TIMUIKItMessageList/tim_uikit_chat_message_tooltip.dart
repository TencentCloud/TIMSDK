// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/utils/screen_utils.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
import 'package:tim_ui_kit/ui/widgets/forward_message_screen.dart';

import '../TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_select_emoji.dart';

class TIMUIKitMessageTooltip extends StatefulWidget {
  /// tool tips panel configuration, long press message will show tool tips panel
  final ToolTipsConfig? toolTipsConfig;

  /// current message
  final V2TimMessage message;

  /// allow notifi user when send reply message
  final bool allowAtUserWhenReply;

  /// the callback for long press event, except myself avatar
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;

  final bool isUseMessageReaction;

  /// direction
  final SelectEmojiPanelPosition selectEmojiPanelPosition;

  /// on add sticker reaction to a message
  final ValueChanged<int> onSelectSticker;

  /// on close tooltip area
  final VoidCallback onCloseTooltip;

  final TUIChatSeparateViewModel model;

  const TIMUIKitMessageTooltip(
      {Key? key,
      this.toolTipsConfig,
      this.isUseMessageReaction = true,
      required this.model,
      required this.message,
      required this.allowAtUserWhenReply,
      this.onLongPressForOthersHeadPortrait,
      required this.selectEmojiPanelPosition,
      required this.onCloseTooltip,
      required this.onSelectSticker})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitMessageTooltipState();
}

class TIMUIKitMessageTooltipState
    extends TIMUIKitState<TIMUIKitMessageTooltip> {
  bool isShowMoreSticker = false;

  bool isRevocable(int timestamp, int upperTimeLimit) =>
      (DateTime.now().millisecondsSinceEpoch / 1000).ceil() - timestamp <
      upperTimeLimit;

  Widget ItemInkWell({
    Widget? child,
    GestureTapCallback? onTap,
  }) {
    return SizedBox(
      width: 50,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: child,
        ),
      ),
    );
  }

  _buildLongPressTipItem(TUITheme theme, TUIChatSeparateViewModel model) {
    final isCanRevoke = isRevocable(
        widget.message.timestamp!, model.chatConfig.upperRecallTime);
    final shouldShowRevokeAction = isCanRevoke &&
        (widget.message.isSelf ?? false) &&
        widget.message.status != MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL;
    final tooltipsConfig = widget.toolTipsConfig;
    final defaultTipsList = [
      {
        "label": TIM_t("复制"),
        "id": "copyMessage",
        "icon": "images/copy_message.png"
      },
      {
        "label": TIM_t("转发"),
        "id": "forwardMessage",
        "icon": "images/forward_message.png"
      },
      {
        "label": TIM_t("多选"),
        "id": "multiSelect",
        "icon": "images/multi_message.png"
      },
      {
        "label": TIM_t("引用"),
        "id": "replyMessage",
        "icon": "images/reply_message.png"
      },
      {
        "label": TIM_t("删除"),
        "id": "delete",
        "icon": "images/delete_message.png"
      },
      if (shouldShowRevokeAction)
        {
          "label": TIM_t("撤回"),
          "id": "revoke",
          "icon": "images/revoke_message.png"
        }
    ];
    if (widget.message.elemType != MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      defaultTipsList.removeAt(0);
    }
    List formatedTipsList = defaultTipsList;
    if (tooltipsConfig != null) {
      formatedTipsList = defaultTipsList.where((element) {
        final type = element["id"];
        if (type == "copyMessage") {
          return tooltipsConfig.showCopyMessage;
        }
        if (type == "forwardMessage") {
          return tooltipsConfig.showForwardMessage;
        }
        if (type == "replyMessage") {
          return tooltipsConfig.showReplyMessage;
        }
        if (type == "delete") {
          return (!PlatformUtils().isWeb) && tooltipsConfig.showDeleteMessage;
        }
        if (type == "multiSelect") {
          return tooltipsConfig.showMultipleChoiceMessage;
        }

        if (type == "revoke") {
          return tooltipsConfig.showRecallMessage;
        }
        return true;
      }).toList();
    }
    return formatedTipsList
        .map(
          (item) => Material(
            color: Colors.white,
            child: ItemInkWell(
              onTap: () {
                _onTap(item["id"]!, model);
              },
              child: Column(
                children: [
                  Image.asset(
                    item["icon"]!,
                    package: 'tim_ui_kit',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    item["label"]!,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: theme.darkTextColor,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  _onTap(String operation, TUIChatSeparateViewModel model) async {
    final messageItem = widget.message;
    final msgID = messageItem.msgID as String;
    switch (operation) {
      case "delete":
        model.deleteMsg(msgID, webMessageInstance: messageItem.messageFromWeb);
        break;
      case "revoke":
        model.revokeMsg(msgID, messageItem.messageFromWeb);
        break;
      case "multiSelect":
        model.updateMultiSelectStatus(true);
        model.addToMultiSelectedMessageList(widget.message);
        break;
      case "forwardMessage":
        model.addToMultiSelectedMessageList(widget.message);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ForwardMessageScreen(
                      conversationType: ConvType.c2c,
                      model: model,
                    )));
        break;
      case "copyMessage":
        if (widget.message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
          try {
            await Clipboard.setData(
                ClipboardData(text: widget.message.textElem?.text ?? ""));
            onTIMCallback(TIMCallback(
                type: TIMCallbackType.INFO,
                infoRecommendText: TIM_t("已复制"),
                infoCode: 6660408));
          } catch (e) {
            print(e);
          }
        }
        break;
      case "replyMessage":
        model.repliedMessage = widget.message;
        if (widget.allowAtUserWhenReply &&
            widget.onLongPressForOthersHeadPortrait != null &&
            !(widget.message.isSelf ?? false)) {
          widget.onLongPressForOthersHeadPortrait!(
              widget.message.sender, widget.message.nickName);
        }
        break;
      default:
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("暂未实现"),
            infoCode: 6660409));
    }
    widget.onCloseTooltip();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.model),
      ],
      builder: (BuildContext context, Widget? w) {
        final TUIChatSeparateViewModel model =
            Provider.of<TUIChatSeparateViewModel>(context);
        final bool haveExtraTipsConfig = widget.toolTipsConfig != null &&
            widget.toolTipsConfig?.additionalItemBuilder != null;
        Widget? extraTipsActionItem = haveExtraTipsConfig
            ? widget.toolTipsConfig!.additionalItemBuilder!(
                widget.message, widget.onCloseTooltip, null, context)
            : null;
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: min(MediaQuery.of(context).size.width * 0.7, 350),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isUseMessageReaction &&
                      widget.selectEmojiPanelPosition ==
                          SelectEmojiPanelPosition.up)
                    TIMUIKitMessageReactionEmojiSelectPanel(
                      isShowMoreSticker: isShowMoreSticker,
                      onSelect: (int value) => widget.onSelectSticker(value),
                      onClickShowMore: (bool value) {
                        setState(() {
                          isShowMoreSticker = value;
                        });
                      },
                    ),
                  if (widget.isUseMessageReaction &&
                      widget.selectEmojiPanelPosition ==
                          SelectEmojiPanelPosition.up &&
                      isShowMoreSticker == false)
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: const Divider(
                            thickness: 1,
                            indent: 0,
                            // endIndent: 10,
                            color: Colors.black12)),
                  if (isShowMoreSticker == false)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isUseMessageReaction)
                          Expanded(
                              child: Wrap(
                            direction: Axis.horizontal,
                            alignment: ScreenUtils.getFormFactor(context) ==
                                    ScreenType.Handset
                                ? WrapAlignment.spaceAround
                                : WrapAlignment.start,
                            spacing: 4,
                            runSpacing: 16,
                            children: [
                              ..._buildLongPressTipItem(theme, model),
                              if (extraTipsActionItem != null)
                                extraTipsActionItem
                            ],
                          )),
                        if (!widget.isUseMessageReaction)
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: ScreenUtils.getFormFactor(context) ==
                                    ScreenType.Handset
                                ? WrapAlignment.spaceAround
                                : WrapAlignment.start,
                            spacing: 4,
                            runSpacing: 16,
                            children: [
                              ..._buildLongPressTipItem(theme, model),
                              if (extraTipsActionItem != null)
                                extraTipsActionItem
                            ],
                          )
                      ],
                    ),
                  if (widget.isUseMessageReaction &&
                      widget.selectEmojiPanelPosition ==
                          SelectEmojiPanelPosition.down &&
                      isShowMoreSticker == false)
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: const Divider(
                            thickness: 1,
                            indent: 0,
                            // endIndent: 10,
                            color: Colors.black12)),
                  if (widget.isUseMessageReaction &&
                      widget.selectEmojiPanelPosition ==
                          SelectEmojiPanelPosition.down)
                    TIMUIKitMessageReactionEmojiSelectPanel(
                      isShowMoreSticker: isShowMoreSticker,
                      onSelect: (int value) => widget.onSelectSticker(value),
                      onClickShowMore: (bool value) {
                        setState(() {
                          isShowMoreSticker = value;
                        });
                      },
                    ),
                ],
              ),
            ));
      },
    );
  }
}
