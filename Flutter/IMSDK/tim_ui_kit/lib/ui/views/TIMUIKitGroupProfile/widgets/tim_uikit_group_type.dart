import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/shared_data_widget.dart';

class GroupProfileType extends TIMUIKitStatelessWidget {
  GroupProfileType({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    String groupType;
    final model = SharedDataWidget.of(context)?.model;
    if (model == null) {
      return Container();
    }
    final type = model.groupInfo?.groupType;
    switch (type) {
      case GroupType.AVChatRoom:
        groupType = TIM_t("聊天室");
        break;
      case GroupType.Meeting:
        groupType = TIM_t("会议群");
        break;
      case GroupType.Public:
        groupType = TIM_t("公开群");
        break;
      case GroupType.Work:
        groupType = TIM_t("工作群");
        break;
      default:
        groupType = TIM_t("未知群");
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                  color:
                      theme.weakDividerColor ?? CommonColor.weakDividerColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            TIM_t("群类型"),
            style: TextStyle(fontSize: 16, color: theme.darkTextColor),
          ),
          Text(
            groupType,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          )
        ],
      ),
    );
  }
}
