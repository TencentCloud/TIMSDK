import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_member_list.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    Key? key,
  }) : super(key: key);

  List<V2TimGroupMemberFullInfo?> _getMemberList(memberList) {
    if (memberList.length > 8) {
      return memberList.getRange(0, 8).toList();
    } else {
      return memberList;
    }
  }

  _getShowName(V2TimGroupMemberFullInfo? item) {
    final friendRemark = item?.friendRemark ?? "";
    final nickName = item?.nickName ?? "";
    final userID = item?.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  List<Widget> _groupMemberListBuilder(memberList, theme) {
    return _getMemberList(memberList).map((element) {
      final faceUrl = element?.faceUrl ?? "";
      final showName = _getShowName(element);
      return Container(
        margin: const EdgeInsets.only(right: 21),
        child: Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              showName,
              style: TextStyle(color: theme.weakTextColor, fontSize: 10),
            )
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _inviteMemberBuilder(bool isCanInviteMember,
      bool isCanKickOffMember, theme, BuildContext context) {
    return [];
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
          final isCanInviteMember =
              Provider.of<TUIGroupProfileViewModel>(context).canInviteMember();
          final isCanKickOffMember =
              Provider.of<TUIGroupProfileViewModel>(context).canKickOffMember();
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          final I18nUtils ttBuild = I18nUtils(context);
          return InkWell(
            onTap: () async {
              final connectivityResult =
                  await (Connectivity().checkConnectivity());
              if (connectivityResult == ConnectivityResult.none) {
                final I18nUtils ttBuild = I18nUtils(context);
                Fluttertoast.showToast(
                  msg: ttBuild.imt("无网络连接，无法查看群成员"),
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                );
                return;
              }
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              ttBuild.imt_para(
                                      "{{memberCount}}人", "$memberCount人")(
                                  memberCount: memberCount),
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
                    // height: 90,
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      // spacing: 21,
                      runSpacing: 10,
                      alignment: WrapAlignment.start,
                      children: [
                        ..._groupMemberListBuilder(memberList, theme),
                        if (isCanInviteMember)
                          DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(4.5),
                              color: theme.weakTextColor!,
                              dashPattern: const [6, 3],
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddGroupMemberPage(model: model),
                                        ));
                                  },
                                  icon: const Icon(Icons.add),
                                  color: theme.weakTextColor,
                                ),
                              )),
                        if (isCanInviteMember)
                          const SizedBox(
                            width: 21,
                          ),
                        if (isCanKickOffMember)
                          DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(4.5),
                              color: theme.weakTextColor!,
                              dashPattern: const [6, 3],
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DeleteGroupMemberPage(
                                                  model: model),
                                        ));
                                  },
                                  icon: const Icon(Icons.remove),
                                  color: theme.weakTextColor,
                                ),
                              )),
                      ],
                    ),
                  ),
                  if (memberList.length > 8)
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 16),
                      child: Text(
                        ttBuild.imt("查看更多群成员"),
                        style:
                            TextStyle(color: theme.weakTextColor, fontSize: 14),
                      ),
                    )
                ],
              ),
            ),
          );
        });
  }
}
