import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';

import '../../../i18n/i18n_utils.dart';

class GroupProfileAddOpt extends StatelessWidget {
  const GroupProfileAddOpt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    final _model = SharedDataWidget.of(context)?.model;
    if (_model == null) {
      return Container();
    }
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          final model = Provider.of<TUIGroupProfileViewModel>(context);

          String addOpt = ttBuild.imt("未知");

          final groupAddOpt = model.groupInfo?.groupAddOpt;
          switch (groupAddOpt) {
            case GroupAddOptType.V2TIM_GROUP_ADD_ANY:
              addOpt = ttBuild.imt("自动审批");
              break;
            case GroupAddOptType.V2TIM_GROUP_ADD_AUTH:
              addOpt = ttBuild.imt("管理员审批");
              break;
            case GroupAddOptType.V2TIM_GROUP_ADD_FORBID:
              addOpt = ttBuild.imt("禁止加群");
              break;
          }

          final actionList = [
            {
              "label": ttBuild.imt("禁止加群"),
              "id": GroupAddOptType.V2TIM_GROUP_ADD_FORBID
            },
            {
              "label": ttBuild.imt("自动审批"),
              "id": GroupAddOptType.V2TIM_GROUP_ADD_ANY
            },
            {
              "label": ttBuild.imt("管理员审批"),
              "id": GroupAddOptType.V2TIM_GROUP_ADD_AUTH
            }
          ];

          _handleActionTap(int addOpt) async {
            model.setGroupAddOpt(addOpt).then((res) {
              if (res != null && res.code != 0) {
                Fluttertoast.showToast(
                  msg: res.desc,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                );
              }
            });
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
                        color: theme.weakDividerColor ??
                            CommonColor.weakDividerColor))),
            child: InkWell(
              onTap: () async {
                final connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  final I18nUtils ttBuild = I18nUtils(context);
                  Fluttertoast.showToast(
                    msg: ttBuild.imt("无网络连接，无法修改"),
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                  );
                  return;
                }
                showCupertinoModalPopup<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      title: Text(ttBuild.imt("加群方式")),
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            "cancel",
                          );
                        },
                        child: Text(ttBuild.imt("取消")),
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
                    ttBuild.imt("加群方式"),
                    style: TextStyle(fontSize: 16, color: theme.darkTextColor),
                  ),
                  Row(
                    children: [
                      Text(
                        addOpt,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Icon(Icons.keyboard_arrow_right,
                          color: theme.weakTextColor)
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
