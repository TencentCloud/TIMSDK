import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class CheckBoxButton extends TIMUIKitStatelessWidget {
  final bool isChecked;
  final Function(bool isChecked)? onChanged;

  CheckBoxButton({Key? key, required this.isChecked, this.onChanged})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final boxDecoration = !isChecked
        ? BoxDecoration(
            border: Border.all(color: hexToColor("888888")),
            shape: BoxShape.circle,
            color: Colors.white)
        : BoxDecoration(shape: BoxShape.circle, color: theme.primaryColor);
    return Center(
        child: InkWell(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!isChecked);
        }
      },
      child: Container(
        height: 22,
        width: 22,
        decoration: boxDecoration,
        child: const Icon(
          Icons.check,
          size: 11.0,
          color: Colors.white,
        ),
      ),
    ));
  }
}
