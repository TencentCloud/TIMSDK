import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class UnreadMessage extends TIMUIKitStatelessWidget {
  final int unreadCount;
  final double? width;
  final double? height;
  UnreadMessage(
      {Key? key,
      required this.unreadCount,
      this.width = 22.0,
      this.height = 22.0})
      : super(key: key);

  String generateUnreadText() =>
      unreadCount > 99 ? '99+' : unreadCount.toString();
  double generateFontSize(String text) => text.length * -2 + 13;

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final unreadText = generateUnreadText();
    final fontSize = generateFontSize(unreadText);
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.cautionColor ?? CommonColor.cautionColor,
      ),
      child: unreadText != "0"
          ? Center(
              child: Text(unreadText,
                  style: TextStyle(color: Colors.white, fontSize: fontSize)),
            )
          : null,
    );
  }
}
