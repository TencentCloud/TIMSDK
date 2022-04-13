// ignore_for_file: avoid_print, empty_catches

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_draft_text.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_last_msg.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/unread_message.dart';

class TIMUIKitConversationItem extends StatelessWidget {
  final String faceUrl;
  final String nickName;
  final V2TimMessage? lastMsg;
  final int unreadCount;
  final bool isPined;
  final List<V2TimGroupAtInfo?> groupAtInfoList;
  final String? draftText;
  final int? draftTimestamp;
  final bool isDisturb;

  const TIMUIKitConversationItem(
      {Key? key,
      required this.faceUrl,
      required this.nickName,
      required this.lastMsg,
      required this.isPined,
      required this.unreadCount,
      required this.groupAtInfoList,
      required this.isDisturb,
      this.draftText,
      this.draftTimestamp})
      : super(key: key);

  Widget _getShowMsgWidget(BuildContext context) {
    if (draftText != null) {
      return TIMUIKitDraftText(
        context: context,
        draftText: draftText ?? "",
      );
    } else if (lastMsg != null) {
      return TIMUIKitLastMsg(
        groupAtInfoList: groupAtInfoList,
        lastMsg: lastMsg,
        context: context,
      );
    }

    return Container(
      height: 14,
    );
  }

  Widget _getTimeStringForChatWidget(BuildContext context, TUITheme theme) {
    try {
      if (draftTimestamp != null && draftTimestamp != 0) {
        return Text(
            TimeAgo(context).getTimeStringForChat(draftTimestamp as int),
            style: TextStyle(
              fontSize: 12,
              color: theme.weakTextColor,
            ));
      } else if (lastMsg != null) {
        return Text(
            TimeAgo(context).getTimeStringForChat(lastMsg!.timestamp as int),
            style: TextStyle(
              fontSize: 12,
              color: theme.weakTextColor,
            ));
      }
    } catch (err) {
    
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final theme = value.theme;
          return Container(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            color: isPined ? theme.weakBackgroundColor : Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        Avatar(faceUrl: faceUrl, showName: nickName),
                        if (unreadCount != 0)
                          Positioned(
                            top: isDisturb ? -2.5 : -4.5,
                            right: isDisturb ? -2.5 : -4.5,
                            child: UnconstrainedBox(
                              child: UnreadMessage(
                                  width: isDisturb ? 10 : 22,
                                  height: isDisturb ? 10 : 22,
                                  unreadCount: isDisturb ? 0 : unreadCount),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.weakDividerColor ??
                                  CommonColor.weakDividerColor,
                              width: 1))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(
                            nickName,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400),
                          )),
                          _getTimeStringForChatWidget(context, theme),
                        ],
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
                                size: 18.0,
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
        }));
  }
}
