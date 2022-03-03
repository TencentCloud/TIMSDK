import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/time_ago.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_last_msg.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class TIMUIKitConversationItem extends StatelessWidget {
  final String faceUrl;
  final String nickName;
  final V2TimMessage? lastMsg;
  final int unreadCount;
  final bool isPined;
  final List<V2TimGroupAtInfo?> groupAtInfoList;

  const TIMUIKitConversationItem(
      {Key? key,
      required this.faceUrl,
      required this.nickName,
      required this.lastMsg,
      required this.isPined,
      required this.unreadCount,
      required this.groupAtInfoList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final theme = value.theme;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 18, 0),
            color: isPined ? theme.weakBackgroundColor : Colors.white,
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    // overflow: Overflow.clip,
                    children: [
                      Avatar(faceUrl: faceUrl, showName: nickName),
                      if (unreadCount != 0)
                        Positioned(
                          top: -4.5,
                          right: -4.5,
                          child: UnconstrainedBox(
                            child: Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: theme.cautionColor,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        )
                    ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // height: 24,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              nickName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400),
                            ),
                            if (lastMsg != null)
                              Text(
                                  TimeAgo(context).getTimeStringForChat(
                                      lastMsg!.timestamp as int),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.weakTextColor,
                                  ))
                          ],
                        ),
                      ),
                      if (lastMsg != null)
                        TIMUIKitLastMsg(
                          groupAtInfoList: groupAtInfoList,
                          lastMsg: lastMsg,
                          context: context,
                        )
                    ],
                  ),
                ))
              ],
            ),
          );
        }));
  }
}
