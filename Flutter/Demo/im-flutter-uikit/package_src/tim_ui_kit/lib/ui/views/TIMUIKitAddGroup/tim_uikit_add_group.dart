import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_add_group_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitAddGroup/tim_uikit_send_application.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class TIMUIKitAddGroup extends StatefulWidget {
  const TIMUIKitAddGroup({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitAddGroupState();
}

class _TIMUIKitAddGroupState extends State<TIMUIKitAddGroup> {
  final TextEditingController _controller = TextEditingController();
  final TUIAddGroupViewModel _addGroupViewModel = TUIAddGroupViewModel();
  final TUIThemeViewModel _themeViewModel = serviceLocator<TUIThemeViewModel>();
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;
  bool showResult = false;

  String _getGroupType(String type) {
    final I18nUtils ttBuild = I18nUtils(context);
    String groupType;
    switch (type) {
      case GroupType.AVChatRoom:
        groupType = ttBuild.imt("聊天室");
        break;
      case GroupType.Meeting:
        groupType = ttBuild.imt("会议群");
        break;
      case GroupType.Public:
        groupType = ttBuild.imt("公开群");
        break;
      case GroupType.Work:
        groupType = ttBuild.imt("工作群");
        break;
      default:
        groupType = ttBuild.imt("未知群");
        break;
    }
    return groupType;
  }

  Widget _searchResultItemBuilder(V2TimGroupInfo groupInfo) {
    final theme = _themeViewModel.theme;
    final faceUrl = groupInfo.faceUrl ?? "";
    final groupID = groupInfo.groupID;
    final showName = groupInfo.groupName ?? groupID;
    final groupType = _getGroupType(groupInfo.groupType);
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SendJoinGroupApplication(
                    groupInfo: groupInfo, model: _addGroupViewModel)));
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 12),
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showName,
                  style: const TextStyle(fontSize: 18),
                ),
                // const SizedBox(
                //   height: 4,
                // ),
                Text(
                  "ID: $groupID",
                  style: TextStyle(fontSize: 12, color: theme.weakTextColor),
                ),
                Text(
                  "群类型: $groupType",
                  style: TextStyle(fontSize: 12, color: theme.weakTextColor),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _searchResultBuilder(List<V2TimGroupInfo>? searchResult) {
    final noResult = searchResult != null && searchResult.isEmpty;
    final I18nUtils ttbuild = I18nUtils(context);
    if (noResult) {
      return [
        Center(
          child: Text(ttbuild.imt("该群聊不存在")),
        )
      ];
    }
    return searchResult?.map((e) => _searchResultItemBuilder(e)).toList() ?? [];
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final _isFocused = _focusNode.hasFocus;
      isFocused = _isFocused;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttbuild = I18nUtils(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _addGroupViewModel),
        ChangeNotifierProvider.value(value: _themeViewModel),
      ],
      builder: (BuildContext context, Widget? w) {
        final model = Provider.of<TUIAddGroupViewModel>(context);
        final theme = Provider.of<TUIThemeViewModel>(context).theme;
        final searchResult = model.groupResult;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        setState(() {
                          showResult = false;
                        });
                      }
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      final searchParams = _controller.text;
                      if (searchParams.trim().isNotEmpty) {
                        model.searchGroup(searchParams);
                        showResult = true;
                        _focusNode.requestFocus();
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_outlined,
                          color: theme.weakTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        hintStyle: const TextStyle(
                          color: Color(0xffAEA4A3),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: ttbuild.imt("搜索群ID")),
                  )),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isFocused ? 50 : 0,
                    child: TextButton(
                        onPressed: () {
                          final searchParams = _controller.text;
                          if (searchParams.trim().isNotEmpty) {
                            model.searchGroup(searchParams);
                            showResult = true;
                            setState(() {});
                          }
                        },
                        child: Text(
                          ttbuild.imt("搜索"),
                          softWrap: false,
                          style: const TextStyle(color: Colors.black),
                        )),
                  )
                ],
              ),
            ),
            if (showResult)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _searchResultBuilder(searchResult),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
