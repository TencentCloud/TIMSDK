import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/add_group_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitAddGroup/tim_uikit_send_application.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitAddGroup extends StatefulWidget {
  /// The life cycle hooks for adding group business logic
  final AddGroupLifeCycle? lifeCycle;

  /// Navigate to group chat, if user is already a member of the current group.
  final Function(String groupID, V2TimConversation conversation) onTapExistGroup;

  const TIMUIKitAddGroup({Key? key, this.lifeCycle, required this.onTapExistGroup}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitAddGroupState();
}

class _TIMUIKitAddGroupState extends TIMUIKitState<TIMUIKitAddGroup> {
  final TextEditingController _controller = TextEditingController();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final ConversationService _conversationService = serviceLocator<ConversationService>();
  final TUIFriendShipViewModel friendShipViewModel = serviceLocator<TUIFriendShipViewModel>();
  List<V2TimGroupInfo>? _addedGroupList;
  List<V2TimGroupInfo>? groupResult = [];
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;
  bool showResult = false;

  String _getGroupType(String type) {
    String groupType;
    switch (type) {
      case GroupType.AVChatRoom:
        groupType = TIM_t("聊天室");
        break;
      case GroupType.Meeting:
        groupType = TIM_t("会议群");
        break;
      case GroupType.Public:
        groupType = TIM_t("公开群");
        break;
      case GroupType.Work:
        groupType = TIM_t("工作群");
        break;
      default:
        groupType = TIM_t("未知群");
        break;
    }
    return groupType;
  }

  Widget _searchResultItemBuilder(V2TimGroupInfo groupInfo, TUITheme theme) {
    final faceUrl = groupInfo.faceUrl ?? "";
    final groupID = groupInfo.groupID;
    final showName = groupInfo.groupName ?? groupID;
    final groupType = _getGroupType(groupInfo.groupType);
    return InkWell(
      onTap: () async {
        final V2TimConversation? groupConversation = await getGroupConversation(groupID);
        if(groupConversation != null){
          onTIMCallback(TIMCallback(
              type: TIMCallbackType.INFO,
              infoRecommendText: TIM_t("您已是群成员"),
              infoCode: 6660202));
          widget.onTapExistGroup(groupID, groupConversation);
          return;
        }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SendJoinGroupApplication(
                      lifeCycle: widget.lifeCycle,
                      groupInfo: groupInfo,
                    )));
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

  List<Widget> _searchResultBuilder(
      List<V2TimGroupInfo>? searchResult, TUITheme theme) {
    final noResult = searchResult != null && searchResult.isEmpty;
    if (noResult) {
      return [
        Center(
          child: Text(TIM_t("该群聊不存在")),
        )
      ];
    }
    return searchResult
            ?.map((e) => _searchResultItemBuilder(e, theme))
            .toList() ??
        [];
  }

  Future<V2TimConversation?> getGroupConversation(String groupID) async {
    if (_addedGroupList == null || _addedGroupList!.isEmpty) {
      _addedGroupList = await _groupServices.getJoinedGroupList();
    }
    try {
      if ((_addedGroupList?.firstWhere((groupItem) {
        return groupItem.groupID == groupID;
          })) !=
          null) {
        V2TimConversation? conversation;
        conversation = await _conversationService
            .getConversationListByConversationId(convID: "group_$groupID");
        if (conversation == null) {
          await friendShipViewModel.loadGroupListData();
          if (friendShipViewModel.groupList
                  .indexWhere((element) => element.groupID == groupID) >
              -1) {
            final V2TimGroupInfo groupInfo = friendShipViewModel.groupList
                .firstWhere((element) => element.groupID == groupID);
            conversation = V2TimConversation(
              conversationID: "group_$groupID",
              type: 2,
              groupID: groupID,
              showName: groupInfo.groupName,
              groupType: groupInfo.groupType,
            );
          }
        }
        return conversation;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final _isFocused = _focusNode.hasFocus;
      isFocused = _isFocused;
      setState(() {});
    });
    initGroupList();
  }

  void initGroupList() async {
    // Get the joined group list in previous
    _addedGroupList = await _groupServices.getJoinedGroupList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  searchGroup(String params) async {
    final res = await _groupServices.getGroupsInfo(groupIDList: [params]);
    if (res != null) {
      setState((){
        groupResult =
            res.where((e) => e.resultCode == 0).map((e) => e.groupInfo!).toList();
      });
    } else {
      setState((){
        groupResult = [];
      });
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

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
                        searchGroup(searchParams);
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
                        hintText: TIM_t("搜索群ID")),
                  )),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isFocused ? 50 : 0,
                child: TextButton(
                    onPressed: () {
                      final searchParams = _controller.text;
                      if (searchParams.trim().isNotEmpty) {
                        searchGroup(searchParams);
                        showResult = true;
                        setState(() {});
                      }
                    },
                    child: Text(
                      TIM_t("搜索"),
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
                children: _searchResultBuilder(groupResult, theme),
              ),
            ),
          )
      ],
    );
  }
}
