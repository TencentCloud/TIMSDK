import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitOperationItem extends TIMUIKitStatelessWidget {
  final String operationName;

  /// shows on the second line
  final String? operationDescription;
  final bool? operationValue;
  final bool isRightIcon;

  /// if allow to show arrow to right
  final bool showArrowRightIcon;

  /// the operationText widget for replacement, for developers to define what to do
  final Widget? operationRightWidget;
  final String type;
  final void Function(bool newValue)? onSwitchChange;

  TIMUIKitOperationItem(
      {Key? key,
      this.operationDescription,
      required this.operationName,
      this.operationValue,
      this.type = "arrow",
      this.onSwitchChange,
      this.operationRightWidget,
      this.showArrowRightIcon = true,
      this.isRightIcon = true})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(operationName),
                  if (operationDescription != null)
                    Text(
                      operationDescription!,
                      style:
                          TextStyle(color: theme.weakTextColor, fontSize: 12),
                    )
                ],
              ),
            ),
          ),
          type == "switch"
              ? CupertinoSwitch(
                  value: operationValue ?? false,
                  onChanged: onSwitchChange,
                  activeColor: theme.primaryColor,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.6,
                      ),
                      child: operationRightWidget ?? const Text(""),
                    ),
                    isRightIcon
                        ? showArrowRightIcon
                            ? const Icon(Icons.keyboard_arrow_right)
                            : Container(
                                width: 10,
                              )
                        : Container(),
                  ],
                ),
        ],
      ),
    );
  }
}
