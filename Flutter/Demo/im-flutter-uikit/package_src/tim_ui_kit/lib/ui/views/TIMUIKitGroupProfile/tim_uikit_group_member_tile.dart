import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_member_list.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import '../../../i18n/i18n_utils.dart';

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    Key? key,
  }) : super(key: key);

  List<V2TimGroupMemberFullInfo?> _getMemberList(memberList) {
    if (memberList.length > 4) {
      return memberList.getRange(0, 5).toList();
    } else {
      return memberList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = SharedDataWidget.of(context)?.model;
    if (model == null) {
      return Container();
    }
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final memberCount = Provider.of<TUIGroupProfileViewModel>(context)
                  .groupInfo
                  ?.memberCount ??
              0;
          final memberList =
              Provider.of<TUIGroupProfileViewModel>(context).groupMemberList ??
                  [];
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          final I18nUtils ttBuild = I18nUtils(context);
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupProfileMemberListPage(
                        model: model, memberList: memberList),
                  ));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.weakDividerColor ??
                                    CommonColor.weakDividerColor))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ttBuild.imt("群成员"),
                            style: TextStyle(
                                color: theme.darkTextColor, fontSize: 16)),
                        Row(
                          children: [
                            Text(
                              ttBuild.imt_para("{{memberCount}}人", "${memberCount}人")(memberCount: memberCount),
                              style: TextStyle(
                                  color: theme.darkTextColor, fontSize: 16),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: theme.weakTextColor,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 90,
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: _getMemberList(memberList).map((element) {
                        final faceUrl = element?.faceUrl ?? "";
                        final showName = element?.friendRemark ??
                            element?.nameCard ??
                            element?.nickName ??
                            element?.nameCard ??
                            element?.userID ??
                            "";
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Avatar(
                                    faceUrl: faceUrl, showName: showName),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                showName,
                                style: TextStyle(
                                    color: theme.weakTextColor, fontSize: 10),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
