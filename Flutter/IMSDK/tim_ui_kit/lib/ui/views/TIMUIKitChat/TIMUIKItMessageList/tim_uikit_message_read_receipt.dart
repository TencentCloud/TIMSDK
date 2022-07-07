import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/widgets/message_read_receipt.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitMessageReadReceipt extends TIMUIKitStatelessWidget {
  final V2TimMessageReceipt messageReadReceipt;
  final V2TimMessage messageItem;
  final void Function(String)? onTapAvatar;

  TIMUIKitMessageReadReceipt(
      {Key? key,
      required this.messageReadReceipt,
      this.onTapAvatar,
      required this.messageItem})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    return Container(
      padding: const EdgeInsets.only(bottom: 3),
      margin: const EdgeInsets.only(right: 6),
      child: messageReadReceipt.unreadCount == 0
          ? Icon(
              Icons.check_circle_outline,
              size: 18,
              color: theme.weakTextColor,
            )
          : GestureDetector(
              onTap: () {
                if ((messageReadReceipt.readCount ?? 0) > 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessageReadReceipt(
                              onTapAvatar: onTapAvatar,
                              messageItem: messageItem,
                              unreadCount: messageReadReceipt.unreadCount ?? 0,
                              readCount: messageReadReceipt.readCount ?? 0)));
                }
              },
              child: Container(
                width: 14,
                height: 14,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 1.3,
                        color: (messageReadReceipt.readCount ?? 0) > 0
                            ? theme.primaryColor!
                            : theme.weakTextColor!)),
                child: (messageReadReceipt.readCount ?? 0) > 0
                    ? Text(
                        '${messageReadReceipt.readCount}',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 8, color: theme.primaryColor),
                      )
                    : null,
              ),
            ),
    );
  }
}
