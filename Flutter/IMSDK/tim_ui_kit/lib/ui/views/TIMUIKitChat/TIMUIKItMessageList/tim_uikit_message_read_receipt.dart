import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/widgets/message_read_receipt.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitMessageReadReceipt extends TIMUIKitStatelessWidget {
  final V2TimMessage messageItem;
  final void Function(String)? onTapAvatar;

  TIMUIKitMessageReadReceipt(
      {Key? key, this.onTapAvatar, required this.messageItem})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final TUIChatSeparateViewModel model =
        Provider.of<TUIChatSeparateViewModel>(context, listen: false);

    return Selector<TUIChatGlobalModel, V2TimMessageReceipt?>(
      builder: (context, value, child) {
        if (value == null || value.unreadCount == 0 && value.readCount == 0) {
          return Container();
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if ((value.readCount ?? 0) > 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessageReadReceipt(
                          model: model,
                          onTapAvatar: onTapAvatar,
                          messageItem: messageItem,
                          unreadCount: value.unreadCount ?? 0,
                          readCount: value.readCount ?? 0)));
            }
          },
          child: Container(
            padding:
                const EdgeInsets.only(bottom: 3, right: 6, left: 6, top: 6),
            child: (value.unreadCount == 0 && (value.readCount ?? 0) > 0)
                ? Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: theme.weakTextColor,
                  )
                : Container(
                    width: 14,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 1.3,
                            color: (value.readCount ?? 0) > 0
                                ? theme.primaryColor!
                                : theme.weakTextColor!)),
                    child: (value.readCount ?? 0) > 0
                        ? Text(
                            '${value.readCount}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 8, color: theme.primaryColor),
                          )
                        : null,
                  ),
          ),
        );
      },
      selector: (c, model) {
        return model.getMessageReadReceipt(messageItem.msgID ?? "");
      },
    );
  }
}
