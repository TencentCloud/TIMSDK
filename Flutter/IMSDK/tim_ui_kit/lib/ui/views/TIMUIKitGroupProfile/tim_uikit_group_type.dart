import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';

import '../../../i18n/i18n_utils.dart';

class GroupProfileType extends StatelessWidget {
  const GroupProfileType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          String groupType;
          final model = SharedDataWidget.of(context)?.model;
          if (model == null) {
            return Container();
          }
          final type = model.groupInfo?.groupType;
          final theme = value.theme;
          switch (type) {
            case GroupType.AVChatRoom:
              groupType = ttBuild.imt("聊天室");
              break;
            case GroupType.Meeting:
              groupType = ttBuild.imt("会议群");
              break;
            case GroupType.Public:
              groupType = ttBuild.imt("公开群");
              break;
            case GroupType.Work:
              groupType = ttBuild.imt("工作群");
              break;
            default:
              groupType = ttBuild.imt("未知群");
              break;
          }

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(
                        color: theme.weakDividerColor ??
                            CommonColor.weakDividerColor))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ttBuild.imt("群类型"),
                  style: TextStyle(fontSize: 16, color: theme.darkTextColor),
                ),
                Text(
                  groupType,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                )
              ],
            ),
          );
        }));
  }
}
