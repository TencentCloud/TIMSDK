// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_member_search.dart';
import 'package:tim_ui_kit/ui/widgets/group_member_list.dart';

class GroupProfileMemberListPage extends StatefulWidget {
  List<V2TimGroupMemberFullInfo?> memberList;
  TUIGroupProfileModel model;

  GroupProfileMemberListPage({
    Key? key,
    required this.memberList,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => GroupProfileMemberListPageState();
}

class GroupProfileMemberListPageState
    extends TIMUIKitState<GroupProfileMemberListPage> {
  List<V2TimGroupMemberFullInfo?>? searchMemberList;
  String? searchText;

  _kickedOffMember(String userID) async {
    widget.model.kickOffMember([userID]);
  }

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

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.model),
      ],
      builder: (BuildContext context, Widget? w){
        final TUIGroupProfileModel groupProfileModel = Provider.of<
            TUIGroupProfileModel>(context);
        String option1 = groupProfileModel.groupInfo?.memberCount.toString() ??
            widget.memberList.length.toString();
        return Scaffold(
            appBar: AppBar(
                title: Text(
                  TIM_t_para("群成员({{option1}}人)", "群成员($option1人)")(
                      option1: option1),
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
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
              customTopArea: GroupMemberSearchTextField(
                onTextChange: (text) =>
                    handleSearchGroupMembers(text, context),
              ),
              memberList: searchMemberList ?? groupProfileModel.groupMemberList,
              removeMember: _kickedOffMember,
              touchBottomCallBack: () {},
              onTapMemberItem: (friendInfo) {
                if(widget.model.onClickUser != null){
                  widget.model.onClickUser!(friendInfo.userID);
                }
              },
            ));
      },
    );
  }
}
