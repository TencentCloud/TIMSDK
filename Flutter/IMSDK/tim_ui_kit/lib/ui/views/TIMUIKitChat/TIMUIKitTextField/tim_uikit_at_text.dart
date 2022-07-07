import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_param.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
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

class _AtTextState extends State<AtText> {
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
    final res = await _model.searcrhGroupMember(V2TimGroupMemberSearchParam(
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
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
        ...widget.providers ?? [],
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color.fromRGBO(0x73, 0x70, 0xff, 1),
                      Color.fromRGBO(0x33, 0x70, 0xFf, 1),
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
                  ttBuild.imt("选择提醒人"),
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
                      memberList:
                          _groupMemberList ?? value.groupMemberList ?? [],
                      onTapMemberItem: _onTapMemberItem,
                      canAtAll: true,
                      canSlideDelete: false,
                      touchBottomCallBack: () {
                        _model.loadMoreData(groupID: _model.groupInfo!.groupID);
                      },
                      // customTopArea: GroupMemberSearchTextField(
                      //   onTextChange: (text) =>
                      //       handleSearchGroupMembers(text, context),
                      // ),
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
