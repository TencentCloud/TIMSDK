import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

class UnreadMessage extends StatelessWidget {
  final int unreadCount;
  final double width;
  final double height;
  const UnreadMessage(
      {Key? key,
      required this.unreadCount,
      this.width = 22.0,
      this.height = 22.0})
      : super(key: key);

  String generateUnreadText() =>
      unreadCount > 99 ? '99+' : unreadCount.toString();
  double generateFontSize(String text) => text.length * -2 + 14;

  @override
  Widget build(BuildContext context) {
    final unreadText = generateUnreadText();
    final fontSize = generateFontSize(unreadText);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final theme = value.theme;
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.cautionColor ?? CommonColor.cautionColor,
            ),
            child: unreadText != "0"
                ? Text(unreadText,
                    style: TextStyle(color: Colors.white, fontSize: fontSize))
                : null,
          );
        }));
  }
}
