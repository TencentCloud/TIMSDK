import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/forward_message_screen.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';
import 'package:flutter/services.dart';

import '../../../../i18n/i18n_utils.dart';
import '../tim_uikit_chat.dart';

class TIMUIKitHistoryMessageListItem extends StatefulWidget {
  final V2TimMessage messageItem;
  final void Function(String userID)? onTapAvatar;
  final bool isShowNickName;

  final int conversationType;

  final Widget Function(V2TimMessage message, SuperTooltip? tooltip)?
      exteraTipsActionItemBuilder;

  /// 消息构造器
  final Widget? Function(V2TimMessage message)? messageItemBuilder;

  const TIMUIKitHistoryMessageListItem(
      {Key? key,
      required this.messageItem,
      required this.isShowNickName,
      this.onTapAvatar,
      this.messageItemBuilder,
      required this.conversationType,
      this.exteraTipsActionItemBuilder})
      : super(key: key);

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
    extends State<TIMUIKitHistoryMessageListItem> {
  SuperTooltip? tooltip;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUIThemeViewModel themeModel = serviceLocator<TUIThemeViewModel>();
  // bool isChecked = false;

  Stream waitForStateLoading() async* {
    while (!mounted) {
      yield false;
    }
    yield true;
  }

  Future<void> postInit(VoidCallback action) async {
    await for (var isLoaded in waitForStateLoading()) {}
    action();
  }

  @override
  initState() {
    super.initState();
    setState(() {});
    postInit(() {
      initTools();
    });
  }

  _buildeFirstRow() {
    final I18nUtils ttBuild = I18nUtils(context);
    final firstRowList = [
      {"label": ttBuild.imt("复制"), "id": "copyMessage", "icon": "images/copy_message.png"},
      {
        "label": ttBuild.imt("转发"),
        "id": "forwardMessage",
        "icon": "images/forward_message.png"
      },
      {"label": ttBuild.imt("多选"), "id": "multiSelect", "icon": "images/multi_message.png"},
      {"label": ttBuild.imt("引用"), "id": "replyMessage", "icon": "images/reply_message.png"}
    ];
    return firstRowList
        .map((item) => Material(
              child: InkWell(
                onTap: () {
                  _onTap(item["id"]!);
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
            ))
        .toList();
  }

  Widget _getTooltipAction() {
    final isCanRevoke = (DateTime.now().millisecondsSinceEpoch / 1000).ceil() -
            widget.messageItem.timestamp! <
        120;
    final shouldShowRevokeAction =
        isCanRevoke && (widget.messageItem.isSelf ?? false);
    final I18nUtils ttBuild = I18nUtils(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
      height: 131,
      width: 242,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildeFirstRow(),
          ),
          const SizedBox(
            height: 5,
          ),
          const Divider(),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Material(
                child: InkWell(
                  onTap: () {
                    _onTap("delete");
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'images/delete_message.png',
                        package: 'tim_ui_kit',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        ttBuild.imt("删除"),
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
              if (shouldShowRevokeAction) const SizedBox(width: 40),
              if (shouldShowRevokeAction)
                Material(
                  child: InkWell(
                    onTap: () {
                      _onTap("revoke");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/revoke_message.png',
                          package: 'tim_ui_kit',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          ttBuild.imt("撤回"),
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
              // Container()
              if (widget.exteraTipsActionItemBuilder != null)
                InkWell(
                  onTap: () {
                    tooltip?.close();
                  },
                  child: widget.exteraTipsActionItemBuilder!(
                      widget.messageItem, tooltip),
                )
            ],
          )
        ],
      ),
    );
  }

  initTools() {
    tooltip = SuperTooltip(
      popupDirection: TooltipDirection.up,
      minimumOutSidePadding: 0,
      arrowTipDistance: 30,
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
      content: _getTooltipAction(),
    );
    setState(() {});
  }

  _onTap(String operation) async {
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
          Fluttertoast.showToast(msg: ttBuild.imt("已复制"), gravity: ToastGravity.CENTER);
        }
        break;
      case "replyMessage":
        model.setRepliedMessage(widget.messageItem);
        break;
      default:
        Fluttertoast.showToast(msg: ttBuild.imt("暂未实现"), gravity: ToastGravity.CENTER);
    }

    tooltip!.close();
  }

  Widget _messageItemBuilder(V2TimMessage messageItem) {
    final I18nUtils ttBuild = I18nUtils(context);
    final msgType = messageItem.elemType;
    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return Text(ttBuild.imt("[自定义]"));
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return TIMUIKitSoundElem(
            soundElem: messageItem.soundElem!,
            msgID: messageItem.msgID ?? "",
            isFromSelf: messageItem.isSelf ?? false);
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        final isReplyMessage = messageItem.cloudCustomData != null &&
            messageItem.cloudCustomData != "";

        if (isReplyMessage) {
          return TIMUIKitReplyElem(
            message: messageItem,
          );
        }

        return TIMUIKitTextElem(
            text: messageItem.textElem!.text ?? "",
            isFromSelf: messageItem.isSelf ?? false);
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return Text(ttBuild.imt("[表情]"));
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(
            fileElem: messageItem.fileElem,
            isSelf: messageItem.isSelf ?? false);
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return Text(ttBuild.imt("[群系统消息]"));
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElem(
          message: messageItem,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(messageItem);
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return Text(ttBuild.imt("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
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

  Widget _revokedMessageBuilder(theme, String displayName) {
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        ttBuild.imt_para("{{displayName}}撤回了一条消息", "${displayName}撤回了一条消息")(displayName: displayName),
        style: TextStyle(color: theme.weakTextColor, fontSize: 12),
      ),
    );
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

  _onLongPress() {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }
    tooltip = null;
    initTools();
    tooltip!.show(context);
  }

  double getMaxWidth(isSelect) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return width - (isSelect ? 180 : 150);
  }

  Widget _getMessageItemBuilder(V2TimMessage message) {
    final messageBuilder = widget.messageItemBuilder ?? _messageItemBuilder;
    return messageBuilder(widget.messageItem) ??
        _messageItemBuilder(widget.messageItem);
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

    if (isTimeDivider) {
      return _timeDividerBuilder(theme, message.timestamp ?? 0);
    }

    if (isGroupTipsMsg) {
      if (widget.messageItemBuilder != null) {
        final groupTipsMessage = widget.messageItemBuilder!(message);
        return groupTipsMessage ?? _groupTipsMessageBuilder();
      }
      return _groupTipsMessageBuilder();
    }

    if (isRevokedMsg) {
      final displayName = isSelf ? ttBuild.imt("您") : message.nickName ?? message.sender;
      return _revokedMessageBuilder(theme, displayName ?? "");
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isSelf)
                  InkWell(
                    onTap: () {
                      if (widget.onTapAvatar != null) {
                        widget.onTapAvatar!(message.sender ?? "");
                      }
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
                          child: Text(
                            MessageUtils.getDisplayName(message),
                            style: TextStyle(
                                fontSize: 12, color: theme?.weakTextColor),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.conversationType == 1 &&
                              isSelf &&
                              message.status ==
                                  MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC)
                            Container(
                              padding: const EdgeInsets.only(bottom: 3),
                              margin: const EdgeInsets.only(right: 6),
                              child: Text(
                                isPeerRead ? ttBuild.imt("已读") : ttBuild.imt("未读"),
                                style: TextStyle(
                                    color: theme?.weakTextColor, fontSize: 12),
                              ),
                            ),
                          if (isSelf &&
                              message.status ==
                                  MessageStatus.V2TIM_MSG_STATUS_SENDING)
                            Container(
                              padding: const EdgeInsets.only(bottom: 3),
                              margin: const EdgeInsets.only(right: 6),
                              child: Text(
                                ttBuild.imt("发送中..."),
                                style: TextStyle(
                                    color: theme?.weakTextColor, fontSize: 12),
                              ),
                            ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: getMaxWidth(false),
                            ),
                            child: InkWell(
                              child: _getMessageItemBuilder(message),
                              onLongPress: _onLongPress,
                            ),
                          ),
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
        ],
      ),
    );
  }
}
