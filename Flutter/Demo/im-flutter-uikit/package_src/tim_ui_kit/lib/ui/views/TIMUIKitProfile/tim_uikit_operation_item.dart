import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

class TIMUIKitOperationItem extends StatelessWidget {
  final String operationName;
  final bool? operationValue;

  ///是否展示arrow_right图标
  final bool showArrowRightIcon;

  /// 替换operationText组件,使得用户可以自定义展示什么
  final Widget? operationRightWidget;
  final String type;
  final void Function(bool newValue)? onSwitchChange;

  const TIMUIKitOperationItem(
      {Key? key,
      required this.operationName,
      this.operationValue,
      this.type = "arrow",
      this.onSwitchChange,
      this.operationRightWidget,
      this.showArrowRightIcon = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(
            builder: (context, value, child) => Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 1),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(operationName),
                      Expanded(child: Container()),
                      type == "switch"
                          ? CupertinoSwitch(
                              value: operationValue ?? false,
                              onChanged: onSwitchChange,
                              activeColor: value.theme.primaryColor)
                          : Row(
                              children: [
                                operationRightWidget ?? const Text(""),
                                showArrowRightIcon
                                    ? const Icon(Icons.keyboard_arrow_right)
                                    : Container(
                                        width: 10,
                                      )
                              ],
                            ),
                    ],
                  ),
                )));
  }
}
