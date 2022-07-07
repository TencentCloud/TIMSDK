import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_operation_item.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/shared_data_widget.dart';

class GroupMessageDisturb extends TIMUIKitStatelessWidget {
  GroupMessageDisturb({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final model = SharedDataWidget.of(context)?.model;
    return ChangeNotifierProvider.value(
        value: model,
        child: Consumer<TUIGroupProfileViewModel>(
            builder: ((context, value, child) {
          final isDisturb = value.isDisturb ?? false;
          return TIMUIKitOperationItem(
            operationName: TIM_t("消息免打扰"),
            type: "switch",
            operationValue: isDisturb,
            onSwitchChange: (value) {
              model?.setMessageDisturb(value);
            },
          );
        })));
  }
}
