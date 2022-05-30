import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TIMUIKitOperationItem extends StatelessWidget {
  final String operationName;
  final bool? operationValue;
  final bool isRightIcon;

  /// if allow to show arrow to right
  final bool showArrowRightIcon;

  /// the operationText widget for replacement, for developers to define what to do
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
      this.showArrowRightIcon = true,
      this.isRightIcon = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: serviceLocator<TUIThemeViewModel>(),
      child: Consumer<TUIThemeViewModel>(
        builder: (context, value, child) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 1),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(operationName),
              type == "switch"
                  ? CupertinoSwitch(
                      value: operationValue ?? false,
                      onChanged: onSwitchChange,
                      activeColor: value.theme.primaryColor,
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
        ),
      ),
    );
  }
}
