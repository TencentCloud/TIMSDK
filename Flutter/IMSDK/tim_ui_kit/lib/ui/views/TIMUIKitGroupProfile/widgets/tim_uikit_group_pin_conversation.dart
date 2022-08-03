import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_operation_item.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class GroupPinConversation extends TIMUIKitStatelessWidget {
  GroupPinConversation({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final model = Provider.of<TUIGroupProfileModel>(context);
    final isPined = model.conversation?.isPinned ?? false;
    return TIMUIKitOperationItem(
      operationName: TIM_t("置顶聊天"),
      type: "switch",
      operationValue: isPined,
      onSwitchChange: (value) {
        model.pinedConversation(value);
      },
    );
  }
}
