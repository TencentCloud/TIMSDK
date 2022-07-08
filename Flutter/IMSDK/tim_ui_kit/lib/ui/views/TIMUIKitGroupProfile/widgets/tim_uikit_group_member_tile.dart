// ignore_for_file: unused_element

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_member_list.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/shared_data_widget.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class GroupMemberTile extends TIMUIKitStatelessWidget {
  GroupMemberTile({
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
      return Column(
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
      );
    }).toList();
  }

  List<Widget> _inviteMemberBuilder(bool isCanInviteMember,
      bool isCanKickOffMember, theme, BuildContext context) {
    return [];
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final model = SharedDataWidget.of(context)?.model;
    if (model == null) {
      return Container();
    }
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
        ],
        builder: (context, w) {
          final memberAmount = Provider.of<TUIGroupProfileViewModel>(context)
                  .groupInfo
                  ?.memberCount ??
              0;
          final option1 = memberAmount.toString();
          final memberList =
              Provider.of<TUIGroupProfileViewModel>(context).groupMemberList ??
                  [];
          final isCanInviteMember =
              Provider.of<TUIGroupProfileViewModel>(context).canInviteMember();
          final isCanKickOffMember =
              Provider.of<TUIGroupProfileViewModel>(context).canKickOffMember();
          return Container(
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
                  child: InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupProfileMemberListPage(
                                model: model, memberList: memberList),
                          ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(TIM_t("群成员"),
                            style: TextStyle(
                                color: theme.darkTextColor, fontSize: 16)),
                        Row(
                          children: [
                            Text(
                              TIM_t_para("{{option1}}人", "$option1人")(
                                  option1: option1),
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
                ),
                Container(
                  // height: 90,
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 20,
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
                      // if (isCanInviteMember)
                      //   const SizedBox(
                      //     width: 21,
                      //   ),
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
                                            DeleteGroupMemberPage(model: model),
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
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 16),
                      child: Text(
                        TIM_t("查看更多群成员"),
                        style:
                            TextStyle(color: theme.weakTextColor, fontSize: 14),
                      ),
                    ),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupProfileMemberListPage(
                                model: model, memberList: memberList),
                          ));
                    },
                  ),
              ],
            ),
          );
        });
  }
}
