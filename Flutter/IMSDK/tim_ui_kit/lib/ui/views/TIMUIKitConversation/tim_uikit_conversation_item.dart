// ignore_for_file: avoid_print, empty_catches

import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_draft_text.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_last_msg.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/unread_message.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

typedef LastMessageBuilder = Widget Function(
    V2TimMessage? lastMsg, List<V2TimGroupAtInfo?> groupAtInfoList);

class TIMUIKitConversationItem extends TIMUIKitStatelessWidget {
  final String faceUrl;
  final String nickName;
  final V2TimMessage? lastMsg;
  final int unreadCount;
  final bool isPined;
  final List<V2TimGroupAtInfo?> groupAtInfoList;
  final String? draftText;
  final int? draftTimestamp;
  final bool isDisturb;
  final LastMessageBuilder? lastMessageBuilder;
  final V2TimUserStatus? onlineStatus;
  final int? convType;

  /// Control if shows the identifier that the conversation has a draft text, inputted in previous.
  /// Also, you'd better specifying the `draftText` field for `TIMUIKitChat`, from the `draftText` in `V2TimConversation`,
  /// to meet the identifier shows here.
  final bool isShowDraft;

  TIMUIKitConversationItem({
    Key? key,
    required this.isShowDraft,
    required this.faceUrl,
    required this.nickName,
    required this.lastMsg,
    this.onlineStatus,
    required this.isPined,
    required this.unreadCount,
    required this.groupAtInfoList,
    required this.isDisturb,
    this.draftText,
    this.draftTimestamp,
    this.lastMessageBuilder,
    this.convType,
  }) : super(key: key);

  Widget _getShowMsgWidget(BuildContext context) {
    if (isShowDraft && draftText != null && draftText != "") {
      return TIMUIKitDraftText(
        context: context,
        draftText: draftText ?? "",
      );
    } else if (lastMsg != null) {
      if (lastMessageBuilder != null) {
        return lastMessageBuilder!(lastMsg, groupAtInfoList);
      }
      return TIMUIKitLastMsg(
        groupAtInfoList: groupAtInfoList,
        lastMsg: lastMsg,
        context: context,
      );
    }

    return Container(
      height: 0,
    );
  }

  bool isHaveSecondLine() {
    return (isShowDraft && draftText != null && draftText != "") ||
        (lastMsg != null);
  }

  Widget _getTimeStringForChatWidget(BuildContext context, TUITheme theme) {
    try {
      if (draftTimestamp != null && draftTimestamp != 0) {
        return Text(TimeAgo().getTimeStringForChat(draftTimestamp as int),
            style: TextStyle(
              fontSize: 12,
              color: theme.weakTextColor,
            ));
      } else if (lastMsg != null) {
        return Text(TimeAgo().getTimeStringForChat(lastMsg!.timestamp as int),
            style: TextStyle(
              fontSize: 12,
              color: theme.weakTextColor,
            ));
      }
    } catch (err) {}

    return Container();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 16),
      decoration: BoxDecoration(
          color: isPined ? theme.weakBackgroundColor : Colors.white,
          border: Border(
              bottom: BorderSide(
                  color: theme.weakDividerColor ?? CommonColor.weakDividerColor,
                  width: 1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 0, bottom: 2, right: 0),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Avatar(
                      onlineStatus: onlineStatus,
                      faceUrl: faceUrl,
                      showName: nickName,
                      type: convType),
                  if (unreadCount != 0)
                    Positioned(
                      top: isDisturb ? -2.5 : -4.5,
                      right: isDisturb ? -2.5 : -4.5,
                      child: UnconstrainedBox(
                        child: UnreadMessage(
                            width: isDisturb ? 10 : 18,
                            height: isDisturb ? 10 : 18,
                            unreadCount: isDisturb ? 0 : unreadCount),
                      ),
                    )
                ],
              ),
            ),
          ),
          Expanded(
              child: Container(
            height: 60,
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      nickName,
                      softWrap: true,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          height: 1,
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    )),
                    _getTimeStringForChatWidget(context, theme),
                  ],
                ),
                if (isHaveSecondLine())
                  const SizedBox(
                    height: 6,
                  ),
                Row(
                  children: [
                    Expanded(child: _getShowMsgWidget(context)),
                    if (isDisturb)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Icon(
                          Icons.notifications_off,
                          color: theme.weakTextColor,
                          size: 16.0,
                        ),
                      )
                  ],
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
