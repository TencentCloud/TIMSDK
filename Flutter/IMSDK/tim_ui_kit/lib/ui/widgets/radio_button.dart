import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

class CheckBoxButton extends StatelessWidget {
  final bool isChecked;
  final Function(bool isChecked)? onChanged;

  const CheckBoxButton({Key? key, required this.isChecked, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final boxDecoration = !isChecked
              ? BoxDecoration(
                  border: Border.all(color: hexToColor("888888")),
                  shape: BoxShape.circle,
                  color: Colors.white)
              : BoxDecoration(
                  shape: BoxShape.circle, color: value.theme.primaryColor);
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
        }));
  }
}
