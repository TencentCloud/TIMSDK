// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_message_tooltip.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_message_read_receipt.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_custom_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_face_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_group_trtc_tips_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/loading.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

import '../TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_select_emoji.dart';

typedef MessageRowBuilder = Widget Function(
  /// current message
  V2TimMessage message,

  /// the message widget for current message, build by your custom builder or our default builder
  Widget messageWidget,

  /// scroll to the specific message, it will shows in the screen center, and call isNeedShowJumpStatus if necessary
  Function onScrollToIndex,

  /// if current message been called to jumped by other message
  bool isNeedShowJumpStatus,

  /// clear the been jumped status, recommend to execute after get 'isNeedShowJumpStatus'
  VoidCallback clearJumpStatus,

  /// scroll to specific message, it will shows on the screen top, without the call isNeedShowJumpStatus
  Function onScrollToIndexBegin,
);

typedef MessageItemContent = Widget? Function(
  V2TimMessage message,
  bool isShowJump,
  VoidCallback clearJump,
);

class MessageItemBuilder {
  /// text message builder
  final MessageItemContent? textMessageItemBuilder;

  /// text message builder for reply message
  final MessageItemContent? textReplyMessageItemBuilder;

  /// custom message builder
  final MessageItemContent? customMessageItemBuilder;

  /// image message builder
  final MessageItemContent? imageMessageItemBuilder;

  /// sound message builder
  final MessageItemContent? soundMessageItemBuilder;

  /// video message builder
  final MessageItemContent? videoMessageItemBuilder;

  /// file message builder
  final MessageItemContent? fileMessageItemBuilder;

  /// location message (LBS) item builder;
  /// recommend to use our LBS plug-in: https://pub.dev/packages/tim_ui_kit_lbs_plugin
  final MessageItemContent? locationMessageItemBuilder;

  /// face message, like emoji, message builder
  final MessageItemContent? faceMessageItemBuilder;

  /// group tips message builder
  final MessageItemContent? groupTipsMessageItemBuilder;

  /// merger message builder
  final MessageItemContent? mergerMessageItemBuilder;

  /// group calling message builder, show without avatar and nickname
  final MessageItemContent? groupTRTCTipsItemBuilder;

  /// the builder for the whole message line, expect for those message type without avatar and nickname.
  final MessageRowBuilder? messageRowBuilder;

  MessageItemBuilder({
    this.locationMessageItemBuilder,
    this.textMessageItemBuilder,
    this.textReplyMessageItemBuilder,
    this.customMessageItemBuilder,
    this.imageMessageItemBuilder,
    this.soundMessageItemBuilder,
    this.videoMessageItemBuilder,
    this.fileMessageItemBuilder,
    this.faceMessageItemBuilder,
    this.groupTipsMessageItemBuilder,
    this.mergerMessageItemBuilder,
    this.messageRowBuilder,
    this.groupTRTCTipsItemBuilder,
  });
}

class ToolTipsConfig {
  final bool showReplyMessage;
  final bool showMultipleChoiceMessage;
  final bool showDeleteMessage;
  final bool showRecallMessage;
  final bool showCopyMessage;
  final bool showForwardMessage;
  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? additionalItemBuilder;

  ToolTipsConfig(
      {this.showDeleteMessage = true,
      this.showMultipleChoiceMessage = true,
      this.showRecallMessage = true,
      this.showReplyMessage = true,
      this.showCopyMessage = true,
      this.showForwardMessage = true,
      this.additionalItemBuilder});
}

class TIMUIKitHistoryMessageListItem extends StatefulWidget {
  /// message instance
  final V2TimMessage message;

  /// tap remote user avatar callback function
  final void Function(String userID)? onTapForOthersPortrait;

  /// the function use for reply message, when click replied message can scroll to it.
  final Function? onScrollToIndex;

  /// message is too long should scroll this message to begin so that the tool tips panel can show correctlly.
  final Function? onScrollToIndexBegin;

  /// the callback for long press event, except myself avatar
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;

  /// message item builder, works for customize all message types and row layout.
  final MessageItemBuilder? messageItemBuilder;

  /// controll avatart hide or show
  final bool showAvatar;

  /// message sending status
  final bool showMessageSending;

  /// message is read status
  final bool showMessageReadRecipt;

  /// message read status in group
  final bool showGroupMessageReadRecipt;

  /// allow message can long press
  final bool allowLongPress;

  /// allow avatar can tap
  final bool allowAvatarTap;

  /// allow notifi user when send reply message
  final bool allowAtUserWhenReply;

  @Deprecated("Nickname will not show in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
  /// allow show user nick name
  final bool showNickName;

  /// on message long press callback
  final Function(BuildContext context, V2TimMessage message)? onLongPress;

  /// tool tips panel configuration, long press message will show tool tips panel
  final ToolTipsConfig? toolTipsConfig;

  /// padding for each message item
  final EdgeInsetsGeometry? padding;

  /// padding for text message、sound message、reply message
  final EdgeInsetsGeometry? textPadding;

  /// avatar builder
  final Widget Function(BuildContext context, V2TimMessage message)?
      userAvatarBuilder;

  /// theme info for message and avatar
  final MessageThemeData? themeData;

  /// builder for nick name row
  final Widget Function(BuildContext context, V2TimMessage message)?
      topRowBuilder;

  /// builder for bottom raw which under message content
  final Widget Function(BuildContext context, V2TimMessage message)?
      bottomRowBuilder;

  // open MessageReaction
  final bool? isUseMessageReaction;

  const TIMUIKitHistoryMessageListItem(
      {Key? key,
      required this.message,
      @Deprecated("Nickname will not show in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
      this.showNickName = false,
      this.onScrollToIndex,
      this.onScrollToIndexBegin,
      this.onTapForOthersPortrait,
      this.messageItemBuilder,
      this.onLongPressForOthersHeadPortrait,
      this.showAvatar = true,
      this.showMessageSending = true,
      this.showMessageReadRecipt = true,
      this.allowLongPress = true,
      this.toolTipsConfig,
      this.onLongPress,
      this.showGroupMessageReadRecipt = false,
      this.allowAtUserWhenReply = true,
      this.allowAvatarTap = true,
      this.userAvatarBuilder,
      this.themeData,
      this.padding,
      this.textPadding,
      this.topRowBuilder,
      this.isUseMessageReaction,
      this.bottomRowBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKItHistoryMessageListItemState();
}

class TipsActionItem extends TIMUIKitStatelessWidget {
  final String label;
  final String icon;
  final String? package;

  TipsActionItem(
      {Key? key, required this.label, required this.icon, this.package})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return Column(
      children: [
        Image.asset(
          icon,
          package: package,
          width: 20,
          height: 20,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: const TextStyle(
            decoration: TextDecoration.none,
            color: Color(0xFF444444),
            fontSize: 10,
          ),
        )
      ],
    );
  }
}

class _TIMUIKItHistoryMessageListItemState
    extends TIMUIKitState<TIMUIKitHistoryMessageListItem>
    with TickerProviderStateMixin {
  SuperTooltip? tooltip;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  // ignore: unused_field
  final MessageService _messageService = serviceLocator<MessageService>();
  final TUISelfInfoViewModel selfInfoModel = serviceLocator<TUISelfInfoViewModel>();
  final TUIThemeViewModel themeModel = serviceLocator<TUIThemeViewModel>();
  // bool isChecked = false;
  final GlobalKey _key = GlobalKey();

  closeTooltip() {
    tooltip?.close();
  }

  bool isReplyMessage(V2TimMessage message) {
    final hasCustomData =
        message.cloudCustomData != null && message.cloudCustomData != "";
    if (hasCustomData) {
      try {
        final CloudCustomData messageCloudCustomData =
            CloudCustomData.fromJson(json.decode(message.cloudCustomData!));
        if (messageCloudCustomData.messageReply != null) {
          MessageRepliedData.fromJson(messageCloudCustomData.messageReply!);
          return true;
        }
        return false;
      } catch (error) {
        return false;
      }
    }
    return false;
  }

  Widget _messageItemBuilder(V2TimMessage messageItem) {
    final msgType = messageItem.elemType;
    final isShowJump = (model.jumpMsgID == messageItem.msgID) &&
        (messageItem.msgID?.isNotEmpty ?? false);
    final MessageItemBuilder? messageItemBuilder = widget.messageItemBuilder;
    final isFromSelf = messageItem.isSelf ?? false;
    void clearJump() {
      // Future.delayed(const Duration(milliseconds: 100), () {
      model.jumpMsgID = "";
      // });
    }

    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        if (messageItemBuilder?.customMessageItemBuilder != null) {
          return messageItemBuilder!.customMessageItemBuilder!(
            messageItem,
            isShowJump,
            () => model.jumpMsgID = "",
          )!;
        }
        return TIMUIKitCustomElem(
          message: messageItem,
          customElem: messageItem.customElem,
          isFromSelf: isFromSelf,
          messageBackgroundColor: widget.themeData?.messageBackgroundColor,
          messageBorderRadius: widget.themeData?.messageBorderRadius,
          messageFontStyle: widget.themeData?.messageTextStyle,
          textPadding: widget.textPadding,
          isShowMessageReaction: widget.isUseMessageReaction,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        if (messageItemBuilder?.soundMessageItemBuilder != null) {
          return messageItemBuilder!.soundMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitSoundElem(
          message: messageItem,
          soundElem: messageItem.soundElem!,
          msgID: messageItem.msgID ?? "",
          isFromSelf: messageItem.isSelf ?? false,
          clearJump: clearJump,
          isShowJump: isShowJump,
          localCustomInt: messageItem.localCustomInt,
          borderRadius: widget.themeData?.messageBorderRadius,
          fontStyle: widget.themeData?.messageTextStyle,
          backgroundColor: widget.themeData?.messageBackgroundColor,
          textPadding: widget.textPadding,
          isShowMessageReaction: widget.isUseMessageReaction,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        if (isReplyMessage(messageItem)) {
          if (messageItemBuilder?.textReplyMessageItemBuilder != null) {
            return messageItemBuilder!.textReplyMessageItemBuilder!(
              messageItem,
              isShowJump,
              clearJump,
            )!;
          }
          return TIMUIKitReplyElem(
            message: messageItem,
            clearJump: () => model.jumpMsgID = "",
            isShowJump: isShowJump,
            scrollToIndex: widget.onScrollToIndex ?? () {},
            borderRadius: widget.themeData?.messageBorderRadius,
            fontStyle: widget.themeData?.messageTextStyle,
            backgroundColor: widget.themeData?.messageBackgroundColor,
            textPadding: widget.textPadding,
            chatModel: model,
            isShowMessageReaction: widget.isUseMessageReaction,
          );
        }
        if (messageItemBuilder?.textMessageItemBuilder != null) {
          return messageItemBuilder!.textMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitTextElem(
          chatModel: model,
          message: messageItem,
          isFromSelf: messageItem.isSelf ?? false,
          clearJump: () => model.jumpMsgID = "",
          isShowJump: isShowJump,
          borderRadius: widget.themeData?.messageBorderRadius,
          fontStyle: widget.themeData?.messageTextStyle,
          backgroundColor: widget.themeData?.messageBackgroundColor,
          textPadding: widget.textPadding,
          isShowMessageReaction: widget.isUseMessageReaction,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        if (messageItemBuilder?.faceMessageItemBuilder != null) {
          return messageItemBuilder!.faceMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitFaceElem(
          path: messageItem.faceElem!.data ?? "",
          clearJump: clearJump,
          isShowJump: isShowJump, message: messageItem,
          isShowMessageReaction: widget.isUseMessageReaction,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        if (messageItemBuilder?.fileMessageItemBuilder != null) {
          return messageItemBuilder!.fileMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitFileElem(
          message: messageItem,
          messageID: messageItem.msgID,
          fileElem: messageItem.fileElem,
          isSelf: messageItem.isSelf ?? false,
          clearJump: clearJump,
          isShowJump: isShowJump,
          isShowMessageReaction: widget.isUseMessageReaction,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        if (messageItemBuilder?.groupTipsMessageItemBuilder != null) {
          return messageItemBuilder!.groupTipsMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return Text(TIM_t("[群系统消息]"));
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        if (messageItemBuilder?.imageMessageItemBuilder != null) {
          return messageItemBuilder!.imageMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitImageElem(
          clearJump: () => model.jumpMsgID = "",
          isShowJump: isShowJump,
          message: messageItem,
          isShowMessageReaction: widget.isUseMessageReaction,
          key: Key("${messageItem.seq}_${messageItem.timestamp}"),
        );
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        if (messageItemBuilder?.videoMessageItemBuilder != null) {
          return messageItemBuilder!.imageMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitVideoElem(
          messageItem,
          isShowJump: isShowJump,
          clearJump: () => model.jumpMsgID = "",
          isShowMessageReaction: widget.isUseMessageReaction,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        if (messageItemBuilder?.locationMessageItemBuilder != null) {
          return messageItemBuilder!.locationMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return Text(TIM_t("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        if (messageItemBuilder?.mergerMessageItemBuilder != null) {
          return messageItemBuilder!.mergerMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitMergerElem(
            isShowJump: isShowJump,
            clearJump: clearJump,
            message: messageItem,
            isShowMessageReaction: widget.isUseMessageReaction,
            mergerElem: messageItem.mergerElem!,
            messageID: messageItem.msgID ?? "",
            isSelf: messageItem.isSelf ?? false);
      default:
        return Text(TIM_t("[未知消息]"));
    }
  }

  Widget _groupTipsMessageBuilder() {
    final messageItem = widget.message;
    return Container(
        padding: const EdgeInsets.only(bottom: 20),
        child:
            TIMUIKitGroupTipsElem(groupTipsElem: messageItem.groupTipsElem!));
  }

  Widget _groupTRTCTipsMessageBuilder() {
    final messageItem = widget.message;
    return TIMUIKitGroupTrtcTipsElem(
      key: ValueKey(messageItem.msgID),
      customMessage: messageItem,
    );
  }

  Widget _selfRevokeEditMessageBuilder(theme, model) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text.rich(TextSpan(children: [
          TextSpan(
            text: TIM_t("您撤回了一条消息，"),
            style: TextStyle(color: theme.weakTextColor),
          ),
          TextSpan(
            text: TIM_t("重新编辑"),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                model.editRevokedMsg = widget.message.textElem?.text ?? "";
              },
            style: TextStyle(color: theme.primaryColor),
          )
        ], style: const TextStyle(fontSize: 12))));
  }

  Widget _revokedMessageBuilder(theme, String option2) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          TIM_t_para("{{option2}}撤回了一条消息", "$option2撤回了一条消息")(option2: option2),
          style: TextStyle(color: theme.weakTextColor, fontSize: 12),
        ));
  }

  Widget _timeDividerBuilder(theme, int timeStamp) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        TimeAgo().getTimeForMessage(timeStamp),
        style: widget.themeData?.timelineTextStyle ??
            TextStyle(fontSize: 12, color: theme.weakTextColor),
      ),
    );
  }

  bool isRevokable(int timestamp) =>
      (DateTime.now().millisecondsSinceEpoch / 1000).ceil() - timestamp < 120;

  _onLongPress(c, V2TimMessage message) {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }
    tooltip = null;

    final screenHeight = MediaQuery.of(context).size.height;
    if (context.size!.height + 180 > screenHeight) {
      initTools(context: c, isLongMessage: true);
      if (widget.onScrollToIndexBegin != null) {
        widget.onScrollToIndexBegin!(message);
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        tooltip!.show(c);
      });
    } else {
      initTools(context: c);
      tooltip!.show(c);
    }
  }

  _clickOnCurrentSticker(int sticker) async {
    for(int i = 0; i< 5; i++){
      final res = await _modifySticker(sticker);
      if(res.code == 0){
        break;
      }
    }
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> _modifySticker(int sticker) async {
    return await Future.delayed(const Duration(milliseconds: 50), () async {
      return await MessageReactionUtils.clickOnSticker(widget.message, sticker);
    });
  }

  initTools({
    BuildContext? context,
    bool isLongMessage = false,
  }) {
    double arrowTipDistance = 30;
    TooltipDirection popupDirection = TooltipDirection.up;
    SelectEmojiPanelPosition selectEmojiPanelPosition = SelectEmojiPanelPosition.down;
    if (context != null) {
      RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        Offset offset = box.localToGlobal(Offset.zero);
        if (offset.dy < 300 && !isLongMessage) {
          selectEmojiPanelPosition = SelectEmojiPanelPosition.up;
          popupDirection = TooltipDirection.down;
        }
      }
      arrowTipDistance = (context.size!.height / 2).roundToDouble() +
          (isLongMessage ? -120 : 10);
    }

    tooltip = SuperTooltip(
      popupDirection: popupDirection,
      minimumOutSidePadding: 0,
      arrowTipDistance: arrowTipDistance,
      arrowBaseWidth: 10.0,
      arrowLength: 10.0,
      right: widget.message.isSelf! ? 60 : null,
      left: widget.message.isSelf! ? null : 60,
      borderColor: Colors.white,
      backgroundColor: Colors.white,
      shadowColor: Colors.black26,
      hasShadow: true,
      borderWidth: 1.0,
      showCloseButton: ShowCloseButton.none,
      touchThroughAreaShape: ClipAreaShape.rectangle,
      content: TIMUIKitMessageTooltip(
        toolTipsConfig: widget.toolTipsConfig,
        message: widget.message,
        allowAtUserWhenReply: widget.allowAtUserWhenReply,
        onLongPressForOthersHeadPortrait: widget.onLongPressForOthersHeadPortrait,
        selectEmojiPanelPosition: selectEmojiPanelPosition,
        onCloseTooltip: () => tooltip?.close(),
        onSelectSticker: (int value) {
          tooltip?.close();
          _clickOnCurrentSticker(value);
        },
      ),
    );
  }

  double getMaxWidth(isSelect) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return width - (isSelect ? 180 : 150);
  }

  Widget _getMessageItemBuilder(V2TimMessage message, int? messageStatues) {
    final messageBuilder = _messageItemBuilder;

    return messageBuilder(widget.message);
  }

  // 弹出对话框
  Future<bool?> showResendMsgFailDialg(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(TIM_t("您确定要重发这条消息么？")),
          actions: [
            CupertinoDialogAction(
              child: Text(TIM_t("确定")),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            CupertinoDialogAction(
              child: Text(TIM_t("取消")),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onMsgSendFailIconTap(V2TimMessage message) {
    final convID = model.currentSelectedConv;
    final convType =
        model.currentSelectedConvType == 1 ? ConvType.c2c : ConvType.group;
    MessageUtils.handleMessageError(
        model.reSendFailMessage(
            message: message, convType: convType, convID: convID),
        context);
  }

  @override
  void dispose() {
    super.dispose();
    if (tooltip?.isOpen ?? false) {
      tooltip?.close();
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final message = widget.message;
    final msgType = message.elemType;
    final isSelf = message.isSelf ?? false;
    final msgStatus = message.status;
    final isGroupTipsMsg =
        msgType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS;
    final isRevokedMsg = msgStatus == 6;
    final isTimeDivider = msgType == 11;
    final isPeerRead = message.isPeerRead ?? false;
    final isGroupMessage = widget.message.groupID != null && widget.message.groupID!.isNotEmpty;
    final bool isRevokeEditable =
        widget.message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    final isShowNickNameForSelf = isGroupMessage && model.chatConfig.isShowSelfNameInGroup;
    final isShowNickNameForOthers = isGroupMessage && model.chatConfig.isShowOthersNameInGroup;
    if (isTimeDivider) {
      return _timeDividerBuilder(theme, message.timestamp ?? 0);
    }
    void clearJump() {
      model.jumpMsgID = "";
    }

    if (isGroupTipsMsg) {
      if (widget.messageItemBuilder?.groupTipsMessageItemBuilder != null) {
        final groupTipsMessage =
            widget.messageItemBuilder!.groupTipsMessageItemBuilder!(
          message,
          (model.jumpMsgID == message.msgID),
          clearJump,
        );
        return groupTipsMessage ?? _groupTipsMessageBuilder();
      }
      return _groupTipsMessageBuilder();
    }

    if (MessageUtils.isGroupCallingMessage(message)) {
      if (widget.messageItemBuilder?.groupTRTCTipsItemBuilder != null) {
        final groupTrtcTipsMessage =
            widget.messageItemBuilder!.groupTRTCTipsItemBuilder!(
          message,
          (model.jumpMsgID == message.msgID),
          clearJump,
        );
        return groupTrtcTipsMessage ?? _groupTRTCTipsMessageBuilder();
      }
      return _groupTRTCTipsMessageBuilder();
    }

    if (isRevokedMsg) {
      final displayName =
          isSelf ? TIM_t("您") : message.nickName ?? message.sender;
      return isSelf && isRevokeEditable && isRevokable(message.timestamp!)
          ? _selfRevokeEditMessageBuilder(theme, model)
          : _revokedMessageBuilder(theme, displayName ?? "");
    }

    // 使用自定义行
    if (widget.messageItemBuilder?.messageRowBuilder != null) {
      return widget.messageItemBuilder!.messageRowBuilder!(
        message,
        _getMessageItemBuilder(message, message.status),
        widget.onScrollToIndex ?? () {},
        message.msgID == model.jumpMsgID,
        clearJump,
        widget.onScrollToIndexBegin ?? () {},
      );
    }

    final messageReadReceipt =
        model.getMessageReadReceipt(widget.message.msgID ?? '');

    return Container(
      margin: widget.padding ?? const EdgeInsets.only(bottom: 20),
      child: Row(
        key: _key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.isMultiSelect)
            Container(
              margin: const EdgeInsets.only(right: 12, top: 10),
              child: CheckBoxButton(
                isChecked: model.multiSelectedMessageList.contains(message),
                onChanged: (value) {
                  if (value) {
                    model.addToMultiSelectedMessageList(message);
                  } else {
                    model.removeFromMultiSelectedMessageList(message);
                  }
                },
              ),
            ),
          Expanded(
            child: GestureDetector(
              behavior:
                  model.isMultiSelect ? HitTestBehavior.translucent : null,
              onTap: () {
                if (model.isMultiSelect) {
                  final checked =
                      model.multiSelectedMessageList.contains(message);
                  if (checked) {
                    model.removeFromMultiSelectedMessageList(message);
                  } else {
                    model.addToMultiSelectedMessageList(message);
                  }
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isSelf && widget.showAvatar)
                    InkWell(
                      onTap: () {
                        if (widget.onTapForOthersPortrait != null &&
                            widget.allowAvatarTap) {
                          widget.onTapForOthersPortrait!(message.sender ?? "");
                        }
                      },
                      onLongPress: () {
                        if (widget.onLongPressForOthersHeadPortrait != null) {}
                        widget.onLongPressForOthersHeadPortrait!(
                            message.sender, message.nickName);
                      },
                      child: widget.userAvatarBuilder != null
                          ? widget.userAvatarBuilder!(context, message)
                          : Container(
                              margin: (isSelf && isShowNickNameForSelf) ||
                                      (!isSelf && isShowNickNameForOthers)
                                  ? const EdgeInsets.only(top: 2)
                                  : null,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Avatar(
                                    borderRadius:
                                        widget.themeData?.avatarBorderRadius,
                                    faceUrl: message.faceUrl ?? "",
                                    showName:
                                        MessageUtils.getDisplayName(message),),
                              ),
                            ),
                    ),
                  Container(
                    margin: widget.showAvatar
                        ? (isSelf
                            ? const EdgeInsets.only(right: 13)
                            : const EdgeInsets.only(left: 13))
                        : null,
                    child: Column(
                      crossAxisAlignment: isSelf
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if ((isSelf && isShowNickNameForSelf) ||
                            (!isSelf && isShowNickNameForOthers))
                          widget.topRowBuilder != null
                              ? widget.topRowBuilder!(context, message)
                              : Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                1.7),
                                    child: Text(
                                      MessageUtils.getDisplayName(message),
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          widget.themeData?.nickNameTextStyle ??
                                              TextStyle(
                                                  fontSize: 12,
                                                  color: theme.weakTextColor),
                                    ),
                                  )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (model.chatConfig.isShowReadingStatus &&
                            widget.showMessageReadRecipt &&
                                model.currentSelectedConvType == 1 &&
                                isSelf &&
                                message.status ==
                                    MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC)
                              Container(
                                padding: const EdgeInsets.only(bottom: 3),
                                margin: const EdgeInsets.only(right: 6),
                                child: Text(
                                  isPeerRead ? TIM_t("已读") : TIM_t("未读"),
                                  style: TextStyle(
                                      color: theme.weakTextColor, fontSize: 12),
                                ),
                              ),
                            if (model.chatConfig.isShowGroupMessageReadReceipt &&
                                model.currentSelectedConvType == 2 &&
                                isSelf &&
                                message.status ==
                                    MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC &&
                                messageReadReceipt != null)
                              TIMUIKitMessageReadReceipt(
                                messageItem: widget.message,
                                onTapAvatar: widget.onTapForOthersPortrait,
                                messageReadReceipt: messageReadReceipt,
                              ),
                            if (widget.showMessageSending &&
                                isSelf &&
                                message.status ==
                                    MessageStatus.V2TIM_MSG_STATUS_SENDING)
                              Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                margin: const EdgeInsets.only(right: 4),
                                child: const Loading(),
                              ),
                            if (isSelf &&
                                message.status ==
                                    MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL)
                              Container(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  margin: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final reSend =
                                          await showResendMsgFailDialg(context);
                                      if (reSend != null) {
                                        _onMsgSendFailIconTap(message);
                                      }
                                    },
                                    child: Icon(Icons.error,
                                        color: theme.cautionColor, size: 18),
                                  )),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: getMaxWidth(false),
                              ),
                              child: Builder(builder: (context) {
                                return GestureDetector(
                                  child: IgnorePointer(
                                      ignoring: model.isMultiSelect,
                                      child: _getMessageItemBuilder(
                                          message, message.status)),
                                  onLongPress: () {
                                    if (widget.allowLongPress) {
                                      _onLongPress(context, message);
                                    }
                                    if (widget.onLongPress != null) {
                                      widget.onLongPress!(context, message);
                                    }
                                  },
                                );
                              }),
                            ),
                            if (!isSelf &&
                                message.elemType ==
                                    MessageElemType.V2TIM_ELEM_TYPE_SOUND &&
                                message.localCustomInt != null &&
                                message.localCustomInt !=
                                    HistoryMessageDartConstant.read)
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, bottom: 12),
                                  child: Icon(Icons.circle,
                                      color: theme.cautionColor, size: 10)),
                          ],
                        ),
                        if (widget.bottomRowBuilder != null)
                          widget.bottomRowBuilder!(context, message)
                      ],
                    ),
                  ),
                  if (isSelf && widget.showAvatar)
                    widget.userAvatarBuilder != null
                        ? widget.userAvatarBuilder!(context, message)
                        : SizedBox(
                            width: 40,
                            height: 40,
                            child: Avatar(
                                borderRadius:
                                    widget.themeData?.avatarBorderRadius,
                                faceUrl: message.faceUrl ?? "",
                                showName: MessageUtils.getDisplayName(message)),
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
