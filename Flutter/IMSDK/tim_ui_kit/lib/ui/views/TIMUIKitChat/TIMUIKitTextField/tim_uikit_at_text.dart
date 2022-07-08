import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_member_search.dart';
import 'package:tim_ui_kit/ui/widgets/group_member_list.dart';

class AtText extends StatefulWidget {
  final String? groupID;
  final List<SingleChildWidget>? providers;

  /// some Group type cant @all
  final String? groupType;
  const AtText({
    this.groupID,
    this.groupType,
    this.providers,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AtTextState();
}

class _AtTextState extends TIMUIKitState<AtText> {
  final TUIGroupProfileViewModel _model = TUIGroupProfileViewModel();
  List<V2TimGroupMemberFullInfo?>? _groupMemberList;
  @override
  void initState() {
    super.initState();
    if (widget.groupID != null) {
      _model.loadData(widget.groupID!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _model.dispose();
  }

  _onTapMemberItem(V2TimGroupMemberFullInfo memberInfo) {
    Navigator.pop(context, memberInfo);
  }

  handleSearchGroupMembers(String searchText, context) async {
    List<V2TimGroupMemberFullInfo?> currentGroupMember =
        Provider.of<TUIGroupProfileViewModel>(context, listen: false)
                .groupMemberList ??
            [];
    final res = await _model.searchGroupMember(V2TimGroupMemberSearchParam(
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
      currentGroupMember = list;
    }

    setState(() {
      _groupMemberList =
          isSearchTextExist(searchText) ? currentGroupMember : null;
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
        body: ChangeNotifierProvider.value(
            value: _model,
            child: Consumer<TUIGroupProfileViewModel>(
                builder: ((context, value, child) {
              return GroupProfileMemberList(
                  groupType: widget.groupType ?? "",
                  memberList: _groupMemberList ?? value.groupMemberList ?? [],
                  onTapMemberItem: _onTapMemberItem,
                  canAtAll: true,
                  canSlideDelete: false,
                  touchBottomCallBack: () {
                    _model.loadMoreData(groupID: _model.groupInfo!.groupID);
                  },
                  customTopArea: GroupMemberSearchTextField(
                    onTextChange: (text) =>
                        handleSearchGroupMembers(text, context),
                  ));
            }))));
  }
}
