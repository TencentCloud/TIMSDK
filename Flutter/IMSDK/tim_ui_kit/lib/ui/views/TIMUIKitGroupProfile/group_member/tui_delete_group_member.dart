import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/group_member_list.dart';

class DeleteGroupMemberPage extends StatefulWidget {
  final TUIGroupProfileModel model;

  const DeleteGroupMemberPage({Key? key, required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeleteGroupMemberPageState();
}

class _DeleteGroupMemberPageState extends TIMUIKitState<DeleteGroupMemberPage> {
  List<V2TimGroupMemberFullInfo> selectedGroupMember = [];
  List<V2TimGroupMemberFullInfo?>? searchMemberList;

  bool isSearchTextExist(String? searchText) {
    return searchText != null && searchText != "";
  }

  handleSearchGroupMembers(String searchText, context) async {
    searchText = searchText;
    List<V2TimGroupMemberFullInfo?> currentGroupMember =
        Provider.of<TUIGroupProfileModel>(context, listen: false)
            .groupMemberList;
    final res =
    await widget.model.searchGroupMember(V2TimGroupMemberSearchParam(
      keywordList: [searchText],
      groupIDList: [widget.model.groupInfo!.groupID],
    ));

    if (res.code == 0) {
      List<V2TimGroupMemberFullInfo?> list = [];
      final searchResult = res.data!.groupMemberSearchResultItems!;
      searchResult.forEach((key, value) {
        if (value is List) {
          for (V2TimGroupMemberFullInfo item in value) {
            list.add(item);
          }
        }
      });

      currentGroupMember = list;
    } else {
      currentGroupMember = [];
    }
    setState(() {
      searchMemberList =
      isSearchTextExist(searchText) ? currentGroupMember : null;
    });
  }

  handleRole(groupMemberList) {
    return groupMemberList
        ?.where((value) =>
    value?.role ==
        GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER)
        .toList() ??
        [];
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
        appBar: AppBar(
            title: Text(
              TIM_t("删除群成员"),
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedGroupMember.isNotEmpty) {
                    final userIDs =
                    selectedGroupMember.map((e) => e.userID).toList();
                    widget.model.kickOffMember(userIDs);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  TIM_t("确定"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            ],
            shadowColor: theme.weakBackgroundColor,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                  theme.primaryColor ?? CommonColor.primaryColor
                ]),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            )),
        body: GroupProfileMemberList(
          memberList:
          handleRole(searchMemberList ?? widget.model.groupMemberList),
          canSelectMember: true,
          canSlideDelete: false,
          onSelectedMemberChange: (selectedMember) {
            selectedGroupMember = selectedMember;
          },
          touchBottomCallBack: () {
          },
        ));
  }
}