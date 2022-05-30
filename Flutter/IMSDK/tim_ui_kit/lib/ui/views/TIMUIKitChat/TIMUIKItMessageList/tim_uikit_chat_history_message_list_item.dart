// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/shared_theme.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_message_read_receipt.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_custom_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_face_elem.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_group_trtc_tips_elem.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/forward_message_screen.dart';
import 'package:tim_ui_kit/ui/widgets/loading.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';
import 'package:flutter/services.dart';

typedef MessageRowBuilder = Widget Function(
  /// current message
  V2TimMessage message,

  /// the message widget for current message, build by your custom builder or our default builder
  Widget messageWidget,

  /// scroll to the specific message, it will shows in the screen center, and call isNeedShowJumpStatus if necessary
  Function scrollToIndex,

  /// if current message been called to jumped by other message
  bool isNeedShowJumpStatus,

  /// clear the been jumped status, recommend to execute after get 'isNeedShowJumpStatus'
  VoidCallback clearJumpStatus,

  /// scroll to specific message, it will shows on the screen top, without the call isNeedShowJumpStatus
  Function scrollToIndexBegin,
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

class TIMUIKitHistoryMessageListItem extends StatefulWidget {
  final V2TimMessage messageItem;
  final void Function(String userID)? onTapAvatar;
  final bool isShowNickName;

  final int conversationType;

  final Function scrollToIndex;

  final Function scrollToIndexBegin;

  /// the callback for long press event, except myself avatar
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;

  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? exteraTipsActionItemBuilder;

  /// message item builder, works for customize all message types and row layout.
  final MessageItemBuilder? messageItemBuilder;

  /// the callback of clicking message failed icon
  final Function(V2TimMessage message)? onMsgSendFailIconTap;

  const TIMUIKitHistoryMessageListItem({
    Key? key,
    required this.messageItem,
    required this.isShowNickName,
    this.onTapAvatar,
    this.messageItemBuilder,
    required this.conversationType,
    this.exteraTipsActionItemBuilder,
    required this.scrollToIndex,
    this.onLongPressForOthersHeadPortrait,
    this.onMsgSendFailIconTap,
    required this.scrollToIndexBegin,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKItHistoryMessageListItemState();
}

class TipsActionItem extends StatelessWidget {
  final String label;
  final String icon;
  final String? package;

  const TipsActionItem(
      {Key? key, required this.label, required this.icon, this.package})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    extends State<TIMUIKitHistoryMessageListItem>
    with TickerProviderStateMixin {
  SuperTooltip? tooltip;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUIThemeViewModel themeModel = serviceLocator<TUIThemeViewModel>();
  // bool isChecked = false;
  final GlobalKey _key = GlobalKey();

  _buildLongPressTipItem(TIMUIKitChatConfig? chatConfig) {
    final I18nUtils ttBuild = I18nUtils(context);
    final isCanRevoke = isRevokable(widget.messageItem.timestamp!);
    final shouldShowRevokeAction =
        isCanRevoke && (widget.messageItem.isSelf ?? false);
    final firstRowList = [
      {
        "label": ttBuild.imt("复制"),
        "id": "copyMessage",
        "icon": "images/copy_message.png"
      },
      {
        "label": ttBuild.imt("转发"),
        "id": "forwardMessage",
        "icon": "images/forward_message.png"
      },
      {
        "label": ttBuild.imt("多选"),
        "id": "multiSelect",
        "icon": "images/multi_message.png"
      },
      {
        "label": ttBuild.imt("引用"),
        "id": "replyMessage",
        "icon": "images/reply_message.png"
      },
      {
        "label": ttBuild.imt("删除"),
        "id": "delete",
        "icon": "images/delete_message.png"
      },
      if (shouldShowRevokeAction)
        {
          "label": ttBuild.imt("撤回"),
          "id": "revoke",
          "icon": "images/revoke_message.png"
        }
    ];
    if (widget.messageItem.elemType != MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      firstRowList.removeAt(0);
    }
    return firstRowList
        .map(
          (item) => Material(
            child: ItemInkWell(
              onTap: () {
                _onTap(item["id"]!, chatConfig);
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
                      color: themeModel.theme.darkTextColor,
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

  bool isRevokable(int timestamp) =>
      (DateTime.now().millisecondsSinceEpoch / 1000).ceil() - timestamp < 120;

  Widget ItemInkWell({
    Widget? child,
    GestureTapCallback? onTap,
  }) {
    return SizedBox(
      width: 50,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _getTooltipAction(TIMUIKitChatConfig? chatConfig) {
    Widget? extraTipsActionItem = widget.exteraTipsActionItemBuilder != null
        ? widget.exteraTipsActionItemBuilder!(widget.messageItem, closeTooltip)
        : null;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 250,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            // crossAxisAlignment: crossAxisAlignment.st,
            spacing: 4,
            runSpacing: 24,
            children: [
              ..._buildLongPressTipItem(chatConfig),
              if (extraTipsActionItem != null) extraTipsActionItem
            ],
          ),
        ));
  }

  closeTooltip() {
    tooltip?.close();
  }

  initTools(
      {BuildContext? context,
      bool isLongMessage = false,
      TIMUIKitChatConfig? chatConfig}) {
    double arrowTipDistance = 30;
    TooltipDirection popupDirection = TooltipDirection.up;

    if (context != null) {
      RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        Offset offset = box.localToGlobal(Offset.zero);
        if (offset.dy < 240 && !isLongMessage) {
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
      right: widget.messageItem.isSelf! ? 60 : null,
      left: widget.messageItem.isSelf! ? null : 60,
      borderColor: Colors.white,
      backgroundColor: Colors.white,
      shadowColor: Colors.black26,
      hasShadow: true,
      borderWidth: 1.0,
      showCloseButton: ShowCloseButton.none,
      touchThroughAreaShape: ClipAreaShape.rectangle,
      content: _getTooltipAction(chatConfig),
    );
  }

  _onTap(String operation, [TIMUIKitChatConfig? chatConfig]) async {
    final I18nUtils ttBuild = I18nUtils(context);
    final messageItem = widget.messageItem;
    final msgID = messageItem.msgID as String;
    switch (operation) {
      case "delete":
        model.deleteMsg(msgID);
        break;
      case "revoke":
        model.revokeMsg(msgID);
        break;
      case "multiSelect":
        model.updateMultiSelectStatus(true);
        model.addToMultiSelectedMessageList(widget.messageItem);
        break;
      case "forwardMessage":
        model.addToMultiSelectedMessageList(widget.messageItem);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ForwardMessageScreen(
                      conversationShowName: "",
                      conversationType: 1,
                    )));
        break;
      case "copyMessage":
        if (widget.messageItem.elemType ==
            MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
          await Clipboard.setData(
              ClipboardData(text: widget.messageItem.textElem?.text ?? ""));
          Fluttertoast.showToast(
              msg: ttBuild.imt("已复制"), gravity: ToastGravity.CENTER);
        }
        break;
      case "replyMessage":
        model.setRepliedMessage(widget.messageItem);
        if (chatConfig != null && chatConfig.isAtWhenReply) {
          widget.onLongPressForOthersHeadPortrait!(
              widget.messageItem.sender, widget.messageItem.nickName);
        }
        break;
      default:
        Fluttertoast.showToast(
            msg: ttBuild.imt("暂未实现"), gravity: ToastGravity.CENTER);
    }

    tooltip!.close();
  }

  bool isReplyMessage(V2TimMessage message) {
    final hasCustomdata =
        message.cloudCustomData != null && message.cloudCustomData != "";
    if (hasCustomdata) {
      bool canparse = false;
      try {
        final messageCloudCustomData = json.decode(message.cloudCustomData!);
        CloudCustomData.fromJson(messageCloudCustomData);
        canparse = true;
      } catch (error) {
        canparse = false;
      }
      return canparse;
    }
    return hasCustomdata;
  }

  Widget _messageItemBuilder(V2TimMessage messageItem) {
    final I18nUtils ttBuild = I18nUtils(context);
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
          customElem: messageItem.customElem,
          isFromSelf: isFromSelf,
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
            soundElem: messageItem.soundElem!,
            msgID: messageItem.msgID ?? "",
            isFromSelf: messageItem.isSelf ?? false,
            clearJump: clearJump,
            isShowJump: isShowJump,
            localCustomInt: messageItem.localCustomInt);
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
            scrollToIndex: widget.scrollToIndex,
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
          text: messageItem.textElem!.text ?? "",
          isFromSelf: messageItem.isSelf ?? false,
          clearJump: () => model.jumpMsgID = "",
          isShowJump: isShowJump,
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
          clearJump: () => model.jumpMsgID = "",
          isShowJump: isShowJump,
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
            messageID: messageItem.msgID,
            fileElem: messageItem.fileElem,
            isSelf: messageItem.isSelf ?? false);
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        if (messageItemBuilder?.groupTipsMessageItemBuilder != null) {
          return messageItemBuilder!.groupTipsMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return Text(ttBuild.imt("[群系统消息]"));
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
        );
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        if (messageItemBuilder?.locationMessageItemBuilder != null) {
          return messageItemBuilder!.locationMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return Text(ttBuild.imt("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        if (messageItemBuilder?.mergerMessageItemBuilder != null) {
          return messageItemBuilder!.mergerMessageItemBuilder!(
            messageItem,
            isShowJump,
            clearJump,
          )!;
        }
        return TIMUIKitMergerElem(
            mergerElem: messageItem.mergerElem!,
            messageID: messageItem.msgID ?? "",
            isSelf: messageItem.isSelf ?? false);
      default:
        return Text(ttBuild.imt("[未知消息]"));
    }
  }

  Widget _groupTipsMessageBuilder() {
    final messageItem = widget.messageItem;
    return Container(
        padding: const EdgeInsets.only(bottom: 20),
        child:
            TIMUIKitGroupTipsElem(groupTipsElem: messageItem.groupTipsElem!));
  }

  Widget _groupTRTCTipsMessageBuilder() {
    final messageItem = widget.messageItem;
    return TIMUIKitGroupTrtcTipsElem(
      key: ValueKey(messageItem.msgID),
      customMessage: messageItem,
    );
  }

  Widget _selfRevokeEditMessageBuilder(theme, model) {
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text.rich(TextSpan(children: [
          TextSpan(
            text: ttBuild.imt("您撤回了一条消息，"),
            style: TextStyle(color: theme.weakTextColor),
          ),
          TextSpan(
            text: ttBuild.imt("重新编辑"),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                model.editRevokedMsg = widget.messageItem.textElem?.text ?? "";
              },
            style: TextStyle(color: theme.primaryColor),
          )
        ], style: const TextStyle(fontSize: 12))));
  }

  Widget _revokedMessageBuilder(theme, String option2) {
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          ttBuild.imt_para("{{option2}}撤回了一条消息", "$option2撤回了一条消息")(
              option2: option2),
          style: TextStyle(color: theme.weakTextColor, fontSize: 12),
        ));
  }

  Widget _timeDividerBuilder(theme, int timeStamp) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        TimeAgo(context).getTimeForMessage(timeStamp),
        style: TextStyle(fontSize: 12, color: theme.weakTextColor),
      ),
    );
  }

  _onLongPress(c, V2TimMessage message, TIMUIKitChatConfig? chatConfig) {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }
    tooltip = null;

    final screenHeight = MediaQuery.of(context).size.height;
    if (context.size!.height + 180 > screenHeight) {
      initTools(context: c, isLongMessage: true, chatConfig: chatConfig);
      widget.scrollToIndexBegin(message);
      Future.delayed(const Duration(milliseconds: 500), () {
        tooltip!.show(c);
      });
    } else {
      initTools(context: c, chatConfig: chatConfig);
      tooltip!.show(c);
    }
  }

  double getMaxWidth(isSelect) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return width - (isSelect ? 180 : 150);
  }

  Widget _getMessageItemBuilder(V2TimMessage message, int? messageStatues) {
    final messageBuilder = _messageItemBuilder;
    // Click when blocking sending
    final uikitMessageBuilder = AbsorbPointer(
        absorbing: messageStatues == MessageStatus.V2TIM_MSG_STATUS_SENDING,
        child: _messageItemBuilder(widget.messageItem));

    return messageBuilder(widget.messageItem);
  }

  // 弹出对话框
  Future<bool?> showResendMsgFailDialg(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(ttBuild.imt("您确定要重发这条消息么？")),
          actions: [
            CupertinoDialogAction(
              child: Text(ttBuild.imt("确定")),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            CupertinoDialogAction(
              child: Text(ttBuild.imt("取消")),
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

  @override
  void dispose() {
    super.dispose();
    tooltip?.close();
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final theme = SharedThemeWidget.of(context)?.theme;
    final message = widget.messageItem;
    final msgType = message.elemType;
    final isSelf = message.isSelf ?? false;
    final msgStatus = message.status;
    final isGroupTipsMsg =
        msgType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS;
    final isRevokedMsg = msgStatus == 6;
    final isTimeDivider = msgType == 11;
    final isPeerRead = message.isPeerRead ?? false;
    final bool isRevokeEditable =
        widget.messageItem.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    final chatConfig = Provider.of<TIMUIKitChatConfig>(context);
    if (isTimeDivider) {
      return _timeDividerBuilder(theme, message.timestamp ?? 0);
    }
    void clearJump() {
      // Future.delayed(const Duration(milliseconds: 100), () {
      //   clearJump();
      // });
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
          isSelf ? ttBuild.imt("您") : message.nickName ?? message.sender;
      return isSelf && isRevokeEditable && isRevokable(message.timestamp!)
          ? _selfRevokeEditMessageBuilder(theme, model)
          : _revokedMessageBuilder(theme, displayName ?? "");
    }

    // 使用自定义行
    if (widget.messageItemBuilder?.messageRowBuilder != null) {
      return widget.messageItemBuilder!.messageRowBuilder!(
        message,
        _getMessageItemBuilder(message, message.status),
        widget.scrollToIndex,
        message.msgID == model.jumpMsgID,
        clearJump,
        widget.scrollToIndexBegin,
      );
    }

    final messageReadReceipt =
        model.getMessageReadReceipt(widget.messageItem.msgID ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
                  if (!isSelf)
                    InkWell(
                      onTap: () {
                        if (widget.onTapAvatar != null &&
                            chatConfig.isAllowClickAvatar) {
                          widget.onTapAvatar!(message.sender ?? "");
                        }
                      },
                      onLongPress: () {
                        if (widget.onLongPressForOthersHeadPortrait != null) {}
                        widget.onLongPressForOthersHeadPortrait!(
                            message.sender, message.nickName);
                      },
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Avatar(
                            faceUrl: message.faceUrl ?? "",
                            showName: MessageUtils.getDisplayName(message)),
                      ),
                    ),
                  Container(
                    margin: isSelf
                        ? const EdgeInsets.only(right: 13)
                        : const EdgeInsets.only(left: 13),
                    child: Column(
                      crossAxisAlignment: isSelf
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (widget.isShowNickName)
                          Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width /
                                            1.7),
                                child: Text(
                                  MessageUtils.getDisplayName(message),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme?.weakTextColor),
                                ),
                              )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (chatConfig.isShowReadingStatus &&
                                widget.conversationType == 1 &&
                                isSelf &&
                                message.status ==
                                    MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC)
                              Container(
                                padding: const EdgeInsets.only(bottom: 3),
                                margin: const EdgeInsets.only(right: 6),
                                child: Text(
                                  isPeerRead
                                      ? ttBuild.imt("已读")
                                      : ttBuild.imt("未读"),
                                  style: TextStyle(
                                      color: theme?.weakTextColor,
                                      fontSize: 12),
                                ),
                              ),
                            if (chatConfig.isShowGroupReadingStatus &&
                                widget.conversationType == 2 &&
                                isSelf &&
                                message.status ==
                                    MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC &&
                                messageReadReceipt != null)
                              TIMUIKitMessageReadReceipt(
                                messageItem: widget.messageItem,
                                onTapAvatar: widget.onTapAvatar,
                                messageReadReceipt: messageReadReceipt,
                                theme: theme!,
                              ),
                            if (isSelf &&
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
                                      if (widget.onMsgSendFailIconTap != null) {
                                        final reSend =
                                            await showResendMsgFailDialg(
                                                context);
                                        if (reSend != null) {
                                          widget.onMsgSendFailIconTap!(message);
                                        }
                                      }
                                    },
                                    child: Icon(Icons.error,
                                        color: theme?.cautionColor, size: 18),
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
                                    if (chatConfig.isAllowLongPressMessage) {
                                      _onLongPress(
                                          context, message, chatConfig);
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
                                      color: theme?.cautionColor, size: 10)),
                          ],
                        )
                      ],
                    ),
                  ),
                  if (isSelf)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Avatar(
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
