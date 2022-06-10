import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_tips_elem.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';

class TIMUIKitGroupTipsElem extends StatelessWidget {
  final V2TimGroupTipsElem groupTipsElem;

  const TIMUIKitGroupTipsElem({Key? key, required this.groupTipsElem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupTipsAbstactText =
        MessageUtils.groupTipsMessageAbstract(groupTipsElem, context);
    final theme = Provider.of<TUIThemeViewModel>(context).theme;

    return MessageUtils.wrapMessageTips(
        Container(
          alignment: Alignment.center,
          child: Text(
            groupTipsAbstactText,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        theme);
  }
}
