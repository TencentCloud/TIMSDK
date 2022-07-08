import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/shared_data_widget.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class GroupProfileDetailCard extends TIMUIKitStatelessWidget {
  final V2TimGroupInfo groupInfo;
  final void Function(String groupName)? updateGroupName;
  final TextEditingController controller = TextEditingController();

  GroupProfileDetailCard(
      {Key? key, required this.groupInfo, this.updateGroupName})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final model = SharedDataWidget.of(context)?.model;
    final faceUrl = groupInfo.faceUrl ?? "";
    final groupID = groupInfo.groupID;
    final showName = groupInfo.groupName ?? groupID;
    return InkWell(
      onTap: (() {
        showCupertinoModalPopup<String>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Text(TIM_t("取消")),
                  isDefaultAction: false,
                ),
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      controller.text = groupInfo.groupName ?? "";
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text(TIM_t("修改群名称")),
                                  ),
                                  Divider(
                                      height: 2, color: theme.weakDividerColor),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              fillColor:
                                                  theme.weakBackgroundColor,
                                              filled: true,
                                              isDense: true,
                                              hintText: ''),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          TIM_t("修改群名称"),
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: theme.weakTextColor),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final text =
                                                    controller.text.trim();
                                                if (updateGroupName != null) {
                                                  updateGroupName!(text);
                                                } else {
                                                  model?.setGroupName(text);
                                                }
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text(TIM_t("确定")),
                                            )),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    child: Text(
                      TIM_t("修改群名称"),
                      style: TextStyle(color: theme.primaryColor),
                    ),
                    isDefaultAction: false,
                  )
                ]);
          },
        );
      }),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text("ID: $groupID",
                            style: TextStyle(
                                fontSize: 13, color: theme.weakTextColor))
                      ],
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: theme.weakTextColor,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
