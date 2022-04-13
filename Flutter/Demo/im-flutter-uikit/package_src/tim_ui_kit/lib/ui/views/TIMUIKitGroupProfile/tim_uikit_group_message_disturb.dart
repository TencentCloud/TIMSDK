import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/tim_uikit_operation_item.dart';

class GroupMessageDisturb extends StatelessWidget {
  const GroupMessageDisturb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final model = SharedDataWidget.of(context)?.model;
    return ChangeNotifierProvider.value(
        value: model,
        child: Consumer<TUIGroupProfileViewModel>(
            builder: ((context, value, child) {
          final isDisturb = value.isDisturb ?? false;
          return TIMUIKitOperationItem(
            operationName: ttBuild.imt("消息免打扰"),
            type: "switch",
            operationValue: isDisturb,
            onSwitchChange: (value) {
              model?.setMessageDisturb(value);
            },
          );
        })));
  }
}
