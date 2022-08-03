// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class GroupProfileNameCard extends TIMUIKitStatelessWidget {
  GroupProfileNameCard({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final model = Provider.of<TUIGroupProfileModel>(context);
    if (model == null) {
      return Container();
    }
    final nameCard = model.getSelfNameCard();

    controller.text = nameCard;
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
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              context: context,
              builder: (context) {
                return Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(TIM_t("修改我的群昵称")),
                      ),
                      Divider(height: 2, color: theme.weakDividerColor),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: theme.weakBackgroundColor,
                                  filled: true,
                                  isDense: true,
                                  hintText: ''),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              TIM_t("仅限中文、字母、数字和下划线，2-20个字"),
                              style: TextStyle(
                                  fontSize: 13, color: theme.weakTextColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final text = controller.text.trim();
                                    model.setNameCard(text);
                                    Navigator.pop(context);
                                  },
                                  child: Text(TIM_t("确定")),
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TIM_t("我的群昵称"),
              style: TextStyle(fontSize: 16, color: theme.darkTextColor),
            ),
            Row(
              children: [
                Text(
                  nameCard,
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
