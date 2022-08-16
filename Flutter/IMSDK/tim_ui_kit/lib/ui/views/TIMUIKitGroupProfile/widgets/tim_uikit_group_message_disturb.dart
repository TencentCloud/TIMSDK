import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_operation_item.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class GroupMessageDisturb extends TIMUIKitStatelessWidget {
  GroupMessageDisturb({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final model = Provider.of<TUIGroupProfileModel>(context);
    final isDisturb = model.conversation?.recvOpt != 0;
    return TIMUIKitOperationItem(
      operationName: TIM_t("消息免打扰"),
      type: "switch",
      operationValue: isDisturb,
      onSwitchChange: (value) {
        model.setMessageDisturb(value);
      },
    );
  }
}
