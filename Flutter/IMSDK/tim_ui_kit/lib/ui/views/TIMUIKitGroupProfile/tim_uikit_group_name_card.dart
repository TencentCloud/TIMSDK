import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';

import '../../../i18n/i18n_utils.dart';

class GroupProfileNameCard extends StatelessWidget {
  GroupProfileNameCard({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final theme = value.theme;
          final model = SharedDataWidget.of(context)?.model;
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
                              child: Text(ttBuild.imt("修改我的群昵称")),
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
                                    ttBuild.imt("仅限中文、字母、数字和下划线，2-20个字"),
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
                                          final text = controller.text.trim();
                                          model.setNameCard(text);
                                          Navigator.pop(context);
                                        },
                                        child: Text(ttBuild.imt("确定")),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ttBuild.imt("我的群昵称"),
                    style: TextStyle(fontSize: 16, color: theme.darkTextColor),
                  ),
                  Row(
                    children: [
                      Text(
                        nameCard,
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
        }));
  }
}
