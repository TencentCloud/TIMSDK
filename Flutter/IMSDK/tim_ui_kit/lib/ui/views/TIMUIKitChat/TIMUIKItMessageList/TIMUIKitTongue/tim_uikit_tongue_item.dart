import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';

class TIMUIKitTongueItem extends StatelessWidget {
  /// the callback after clicking
  final VoidCallback onClick;

  /// the value type currently
  final MessageListTongueType valueType;

  /// unread amount currently
  final int unreadCount;

  /// total amount of messages at me
  final String atNum;

  TIMUIKitTongueItem({
    Key? key,
    required this.onClick,
    required this.valueType,
    required this.unreadCount,
    required this.atNum,
  }) : super(key: key);

  Map<MessageListTongueType, String> textType(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final option1 = unreadCount;
    final option2 = atNum;
    final String atMeString = option2 != ""
        ? ttBuild.imt_para("有{{option2}}条@我消息", "有$option2条@我消息")(
            option2: option2)
        : ttBuild.imt("有人@我");

    return {
      MessageListTongueType.toLatest: ttBuild.imt("回到最新位置"),
      MessageListTongueType.showUnread:
          ttBuild.imt_para("{{option1}}条新消息", "$option1条新消息")(option1: option1),
      MessageListTongueType.atMe: atMeString,
      MessageListTongueType.atAll: ttBuild.imt("@所有人"),
    };
  }

  final Map<MessageListTongueType, IconData> iconType = {
    MessageListTongueType.toLatest: Icons.arrow_downward_outlined,
    MessageListTongueType.showUnread: Icons.arrow_downward_outlined,
    MessageListTongueType.atMe: Icons.arrow_upward_outlined,
    MessageListTongueType.atAll: Icons.arrow_upward_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: hexToColor("E5E5E5"), width: 1),
          boxShadow: [
            BoxShadow(
                color: theme.weakDividerColor ?? hexToColor("E6E9EB"),
                offset: const Offset(0.0, 0.0),
                blurRadius: 10,
                spreadRadius: 2),
          ],
        ),
        padding: const EdgeInsets.all(10),
        // width: 112,
        height: 37,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 6),
              child: Icon(
                iconType[valueType],
                color: theme.primaryColor,
                size: 12,
              ),
            ),
            Text(
              textType(context)[valueType] ?? "",
              style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
