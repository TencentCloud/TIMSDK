import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class TIMUIKitDraftText extends TIMUIKitStatelessWidget {
  final BuildContext context;
  final String draftText;

  TIMUIKitDraftText({
    Key? key,
    required this.context,
    required this.draftText,
  }) : super(key: key);

  String _getDraftShowText() {
    final draftShowText = TIM_t("草稿");

    return '[$draftShowText] ';
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    return Row(children: [
      Text(_getDraftShowText(), style: TextStyle(color: theme.cautionColor)),
      Expanded(
          child: Text(
        draftText,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(height: 1.5, color: theme.weakTextColor, fontSize: 14),
      )),
    ]);
  }
}
