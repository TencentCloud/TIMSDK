import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_member_search.dart';
import 'package:tim_ui_kit/ui/widgets/group_member_list.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class AtText extends StatefulWidget {
  final String? groupID;
  final V2TimGroupInfo? groupInfo;
  final List<V2TimGroupMemberFullInfo?>? groupMemberList;
  // some Group type cant @all
  final String? groupType;
  const AtText({
    this.groupID,
    this.groupType,
    Key? key,
    this.groupInfo,
    this.groupMemberList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AtTextState();
}

class _AtTextState extends TIMUIKitState<AtText> {
  final GroupServices _groupServices = serviceLocator<GroupServices>();

  List<V2TimGroupMemberFullInfo?>? groupMemberList;
  List<V2TimGroupMemberFullInfo?>? searchMemberList;

  @override
  void initState() {
    groupMemberList = widget.groupMemberList;
    searchMemberList = groupMemberList;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onTapMemberItem(V2TimGroupMemberFullInfo memberInfo) {
    Navigator.pop(context, memberInfo);
  }

  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMember(
      V2TimGroupMemberSearchParam searchParam) async {
    final res =
        await _groupServices.searchGroupMembers(searchParam: searchParam);

    if (res.code == 0) {}
    return res;
  }

  handleSearchGroupMembers(String searchText, context) async {
    final res = await searchGroupMember(V2TimGroupMemberSearchParam(
      keywordList: [searchText],
      groupIDList: [widget.groupID!],
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
      searchMemberList = list;
    }

    setState(() {
      searchMemberList =
          isSearchTextExist(searchText) ? searchMemberList : groupMemberList;
    });
  }

  bool isSearchTextExist(String? searchText) {
    return searchText != null && searchText != "";
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
          leading: Row(
            children: [
              IconButton(
                padding: const EdgeInsets.only(left: 16),
                constraints: const BoxConstraints(),
                icon: Image.asset(
                  'images/arrow_back.png',
                  package: 'tim_ui_kit',
                  height: 34,
                  width: 34,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          centerTitle: true,
          leadingWidth: 100,
          title: Text(
            TIM_t("选择提醒人"),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
        body: GroupProfileMemberList(
            groupType: widget.groupType ?? "",
            memberList: searchMemberList ?? [],
            onTapMemberItem: _onTapMemberItem,
            canAtAll: true,
            canSlideDelete: false,
            touchBottomCallBack: () {
              // Get all by once, unnecessary to load more
            },
            customTopArea: GroupMemberSearchTextField(
              onTextChange: (text) => handleSearchGroupMembers(text, context),
            )));
  }
}
