import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';

class TIMUIKitAppBarTitle extends StatelessWidget {
  final Widget? title;
  final String conversationShowName;
  final bool showC2cMessageEditStaus;
  final String fromUser;
  final TextStyle? textStyle;

  const TIMUIKitAppBarTitle(
      {Key? key,
      this.title,
      this.textStyle,
      required this.conversationShowName,
      required this.showC2cMessageEditStaus,
      required this.fromUser})
      : super(key: key);

  // String conversationShowName;
  @override
  Widget build(BuildContext context) {
    int status = Provider.of<TUIChatGlobalModel>(context, listen: true)
        .getC2cMessageEditStatus(fromUser);
    if (status == 0) {
      if (title != null) {
        return title!;
      }
      return Text(
        conversationShowName,
        style: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
      );
    } else {
      if (showC2cMessageEditStaus) {
        return Text(
          TIM_t("对方正在输入中..."),
          style: textStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
        );
      } else {
        if (title != null) {
          return title!;
        }
        return Text(
          conversationShowName,
          style: textStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
        );
      }
    }
  }
}
