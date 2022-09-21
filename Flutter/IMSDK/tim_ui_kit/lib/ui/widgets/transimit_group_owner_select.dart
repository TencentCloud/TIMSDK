import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_member_search.dart';
import 'package:tim_ui_kit/ui/widgets/group_member_list.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class SelectTransimitOwner extends StatefulWidget {
  final String? groupID;
  final TUIGroupProfileModel model;
  const SelectTransimitOwner({
    this.groupID,
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectCallInviterState();
}

class _SelectCallInviterState extends TIMUIKitState<SelectTransimitOwner> {
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();
  List<V2TimGroupMemberFullInfo> selectedMember = [];
  List<V2TimGroupMemberFullInfo?>? searchMemberList;
  String? searchText;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isSearchTextExist(String? searchText) {
    return searchText != null && searchText != "";
  }

  handleSearchGroupMembers(String searchText, context) async {
    searchText = searchText;
    List<V2TimGroupMemberFullInfo?> currentGroupMember = widget
        .model.groupMemberList
        .where(
            (element) => element?.userID != _coreServicesImpl.loginInfo.userID)
        .toList();
    final res =
        await widget.model.searchGroupMember(V2TimGroupMemberSearchParam(
      keywordList: [searchText],
      groupIDList: [widget.model.groupInfo!.groupID],
      isSearchMemberNameCard: true,
      isSearchMemberUserID: true,
      isSearchMemberNickName: true,
      isSearchMemberRemark: true,
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

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
        appBar: AppBar(
          shadowColor: theme.weakBackgroundColor,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              TIM_t("取消"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedMember.isNotEmpty) {
                  Navigator.pop(context, selectedMember);
                }
              },
              child: Text(
                TIM_t("完成"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
          centerTitle: true,
          leadingWidth: 100,
          title: const Text(
            "转让群主",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
        body: GroupProfileMemberList(
          customTopArea: PlatformUtils().isWeb
              ? null
              : GroupMemberSearchTextField(
                  onTextChange: (text) =>
                      handleSearchGroupMembers(text, context),
                ),
          memberList: (searchMemberList ?? widget.model.groupMemberList)
              .where((element) =>
                  element?.userID != _coreServicesImpl.loginInfo.userID)
              .toList(),
          canSlideDelete: false,
          canSelectMember: true,
          maxSelectNum: 1,
          onSelectedMemberChange: (member) {
            selectedMember = member;
            setState(() {});
          },
          touchBottomCallBack: () {},
        ));
  }
}
