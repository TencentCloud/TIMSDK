import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class GroupMemberSearchTextField extends TIMUIKitStatelessWidget {
  final Function(String text) onTextChange;
  GroupMemberSearchTextField({Key? key, required this.onTextChange})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    var debounceFunc = OptimizeUtils.debounce(
        (text) => onTextChange(text), const Duration(milliseconds: 300));
    return Container(
      color: Colors.white,
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              border: Border.all(color: theme.weakBackgroundColor!, width: 12)),
          child: TextField(
            onChanged: debounceFunc,
            decoration: InputDecoration(
              hintText: TIM_t("搜索"),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Divider(
            thickness: 1,
            indent: 74,
            endIndent: 0,
            color: theme.weakBackgroundColor,
            height: 0)
      ]),
    );
  }
}
