import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_param.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_ui_group_member_search.dart';
import 'package:tim_ui_kit/ui/widgets/group_member_list.dart';

class SelectCallInviter extends StatefulWidget {
  final String? groupID;
  const SelectCallInviter({
    this.groupID,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectCallInviterState();
}

class _SelectCallInviterState extends State<SelectCallInviter> {
  final TUIGroupProfileViewModel _model = TUIGroupProfileViewModel();
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();
  List<V2TimGroupMemberFullInfo> selectedMember = [];
  List<V2TimGroupMemberFullInfo?>? searchMemberList;
  String? searchText;

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

  bool isSearchTextExist(String? searchText) {
    return searchText != null && searchText != "";
  }

  handleSearchGroupMembers(String searchText, context) async {
    searchText = searchText;
    List<V2TimGroupMemberFullInfo?> currentGroupMember =
        Provider.of<TUIGroupProfileViewModel>(context, listen: false)
                .groupMemberList
                ?.where((element) =>
                    element?.userID != _coreServicesImpl.loginInfo.userID)
                .toList() ??
            [];
    final res = await _model.searcrhGroupMember(V2TimGroupMemberSearchParam(
      keywordList: [searchText],
      groupIDList: [_model.groupInfo!.groupID],
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
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: serviceLocator<TUIThemeViewModel>())
      ],
      builder: (context, w) {
        return Consumer<TUIThemeViewModel>(
            builder: (context, themeModel, child) {
          return Scaffold(
              appBar: AppBar(
                shadowColor: themeModel.theme.weakBackgroundColor,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      themeModel.theme.lightPrimaryColor ??
                          CommonColor.lightPrimaryColor,
                      themeModel.theme.primaryColor ?? CommonColor.primaryColor
                    ]),
                  ),
                ),
                leading: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    ttBuild.imt("取消"),
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
                      ttBuild.imt("完成"),
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
                  "发起呼叫",
                  style: TextStyle(
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
                      customTopArea: GroupMemberSearchTextField(
                        onTextChange: (text) =>
                            handleSearchGroupMembers(text, context),
                      ),
                      memberList:
                          (searchMemberList ?? value.groupMemberList ?? [])
                              .where((element) =>
                                  element?.userID !=
                                  _coreServicesImpl.loginInfo.userID)
                              .toList(),
                      canSlideDelete: false,
                      canSelectMember: true,
                      onSelectedMemberChange: (member) {
                        selectedMember = member;
                        setState(() {});
                      },
                      touchBottomCallBack: () {
                        _model.loadMoreData(groupID: _model.groupInfo!.groupID);
                      },
                    );
                  }))));
        });
      },
    );
  }
}
