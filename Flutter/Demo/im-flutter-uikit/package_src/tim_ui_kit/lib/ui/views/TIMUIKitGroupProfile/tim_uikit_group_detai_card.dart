import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import '../../../i18n/i18n_utils.dart';

class GroupProfileDetailCard extends StatelessWidget {
  final V2TimGroupInfo groupInfo;
  final void Function(String groupName)? updateGroupName;
  final TextEditingController controller = TextEditingController();

  GroupProfileDetailCard(
      {Key? key, required this.groupInfo, this.updateGroupName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final theme = value.theme;
          final faceUrl = groupInfo.faceUrl ?? "";
          final groupID = groupInfo.groupID;
          final showName = groupInfo.groupName ?? groupID;
          final I18nUtils ttBuild = I18nUtils(context);
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
                        child: Text(ttBuild.imt("取消")),
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
                                          child: Text(ttBuild.imt("修改群名称")),
                                        ),
                                        Divider(
                                            height: 2,
                                            color: theme.weakDividerColor),
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
                                                    fillColor: theme
                                                        .weakBackgroundColor,
                                                    filled: true,
                                                    isDense: true,
                                                    hintText: ''),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                ttBuild.imt("修改群名称"),
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
                                                      final text = controller
                                                          .text
                                                          .trim();
                                                      if (updateGroupName !=
                                                          null) {
                                                        updateGroupName!(text);
                                                      }
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(ttBuild.imt("确定")),
                                                  )),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
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
                            ttBuild.imt("修改群名称"),
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
        }));
  }
}
