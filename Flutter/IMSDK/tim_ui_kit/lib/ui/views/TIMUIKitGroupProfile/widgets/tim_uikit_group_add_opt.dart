import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class GroupProfileAddOpt extends TIMUIKitStatelessWidget {
  GroupProfileAddOpt({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final model = Provider.of<TUIGroupProfileModel>(context);

    String addOpt = TIM_t("未知");

    final groupAddOpt = model.groupInfo?.groupAddOpt;
    switch (groupAddOpt) {
      case GroupAddOptType.V2TIM_GROUP_ADD_ANY:
        addOpt = TIM_t("自动审批");
        break;
      case GroupAddOptType.V2TIM_GROUP_ADD_AUTH:
        addOpt = TIM_t("管理员审批");
        break;
      case GroupAddOptType.V2TIM_GROUP_ADD_FORBID:
        addOpt = TIM_t("禁止加群");
        break;
    }

    final actionList = [
      {"label": TIM_t("禁止加群"), "id": GroupAddOptType.V2TIM_GROUP_ADD_FORBID},
      {"label": TIM_t("自动审批"), "id": GroupAddOptType.V2TIM_GROUP_ADD_ANY},
      {"label": TIM_t("管理员审批"), "id": GroupAddOptType.V2TIM_GROUP_ADD_AUTH}
    ];

    _handleActionTap(int addOpt) async {
      model.setGroupAddOpt(addOpt).then((res) {});
      Navigator.pop(
        context,
        "cancel",
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                  color:
                      theme.weakDividerColor ?? CommonColor.weakDividerColor))),
      child: InkWell(
        onTap: () async {
          showCupertinoModalPopup<String>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: Text(TIM_t("加群方式")),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      "cancel",
                    );
                  },
                  child: Text(TIM_t("取消")),
                  isDefaultAction: false,
                ),
                actions: actionList
                    .map((e) => CupertinoActionSheetAction(
                          onPressed: () {
                            _handleActionTap(e["id"] as int);
                          },
                          child: Text(
                            e["label"] as String,
                            style: TextStyle(color: theme.primaryColor),
                          ),
                          isDefaultAction: false,
                        ))
                    .toList(),
              );
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TIM_t("加群方式"),
              style: TextStyle(fontSize: 16, color: theme.darkTextColor),
            ),
            Row(
              children: [
                Text(
                  addOpt,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Icon(Icons.keyboard_arrow_right, color: theme.weakTextColor)
              ],
            )
          ],
        ),
      ),
    );
  }
}
