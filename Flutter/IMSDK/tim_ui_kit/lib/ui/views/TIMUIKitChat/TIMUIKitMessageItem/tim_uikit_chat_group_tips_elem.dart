import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitGroupTipsElem extends TIMUIKitStatelessWidget {
  final V2TimGroupTipsElem groupTipsElem;

  TIMUIKitGroupTipsElem({Key? key, required this.groupTipsElem})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final groupTipsAbstractText =
        MessageUtils.groupTipsMessageAbstract(groupTipsElem);

    return MessageUtils.wrapMessageTips(
        Text(
          groupTipsAbstractText,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: hexToColor("888888")),
        ),
        theme);
  }
}
