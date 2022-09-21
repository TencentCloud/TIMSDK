import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitAppBar/tim_uikit_appbar_title.dart';
import 'package:tuple/tuple.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Appbar config
  final AppBar? config;

  /// Allow show conversation total unread count
  final bool showTotalUnReadCount;

  /// Conversation id
  final String conversationID;

  /// conversation name
  final String conversationShowName;

  /// If allow update the conversation show name automatically.
  final bool isConversationShowNameFixed;

  final bool showC2cMessageEditStaus;

  const TIMUIKitAppBar({
    Key? key,
    this.config,
    this.isConversationShowNameFixed = false,
    this.showTotalUnReadCount = true,
    this.conversationID = "",
    this.conversationShowName = "",
    this.showC2cMessageEditStaus = true,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      config?.preferredSize ?? const Size.fromHeight(56.0);

  @override
  State<StatefulWidget> createState() => _TIMUIKitAppBarState();
}

class _TIMUIKitAppBarState extends TIMUIKitState<TIMUIKitAppBar> {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();

  V2TimFriendshipListener? _friendshipListener;
  V2TimGroupListener? _groupListener;

  String _conversationShowName = "";

  _addConversationShowNameListener() {
    _friendshipListener = V2TimFriendshipListener(
      onFriendInfoChanged: (infoList) {
        try {
          final changedInfo = infoList.firstWhere(
            (element) => element.userID == widget.conversationID,
          );
          if (changedInfo.friendRemark != null) {
            _conversationShowName = changedInfo.friendRemark!;
            setState(() {});
          }
        } catch (e) {
          print(e);
        }
      },
    );
    if (_friendshipListener != null) {
      _friendshipServices.addFriendListener(listener: _friendshipListener!);
    }
  }

  _addGroupListener() {
    _groupListener = V2TimGroupListener(
      onGroupInfoChanged: (groupID, changeInfos) {
        try {
          if (groupID == widget.conversationID) {
            final groupNameChangeInfo = changeInfos.firstWhere((element) =>
                element.type ==
                GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME);
            if (groupNameChangeInfo.value != null) {
              _conversationShowName = groupNameChangeInfo.value!;
              setState(() {});
            }
          }
        } catch (e) {
          print(e);
        }
      },
    );
    if (_groupListener != null) {
      _groupServices.addGroupListener(listener: _groupListener!);
    }
  }

  String _getTotalUnReadCount(int unreadCount) {
    return unreadCount < 99 ? unreadCount.toString() : "99";
  }

  @override
  void initState() {
    super.initState();
    _conversationShowName = widget.conversationShowName;
    if (!widget.isConversationShowNameFixed) {
      _addConversationShowNameListener();
      _addGroupListener();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.isConversationShowNameFixed) {
      _groupServices.removeGroupListener(listener: _groupListener);
      _friendshipServices.removeFriendListener(listener: _friendshipListener);
    }
  }

  @override
  void didUpdateWidget(TIMUIKitAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationShowName != widget.conversationShowName &&
        widget.conversationShowName.isNotEmpty) {
      setState(() {
        _conversationShowName = widget.conversationShowName;
      });
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final setAppbar = widget.config;
    final TUIChatSeparateViewModel chatVM =
        Provider.of<TUIChatSeparateViewModel>(context);
    return AppBar(
      backgroundColor: setAppbar?.backgroundColor,
      actionsIconTheme: setAppbar?.actionsIconTheme,
      foregroundColor: setAppbar?.foregroundColor,
      elevation: setAppbar?.elevation,
      bottom: setAppbar?.bottom,
      bottomOpacity: setAppbar?.bottomOpacity ?? 1.0,
      titleSpacing: setAppbar?.titleSpacing,
      automaticallyImplyLeading: setAppbar?.automaticallyImplyLeading ?? false,
      shadowColor: setAppbar?.shadowColor ?? theme.weakDividerColor,
      excludeHeaderSemantics: setAppbar?.excludeHeaderSemantics ?? false,
      toolbarHeight: setAppbar?.toolbarHeight,
      titleTextStyle: setAppbar?.titleTextStyle,
      toolbarOpacity: setAppbar?.toolbarOpacity ?? 1.0,
      toolbarTextStyle: setAppbar?.toolbarTextStyle,
      flexibleSpace: setAppbar?.flexibleSpace ??
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
      iconTheme: setAppbar?.iconTheme ??
          const IconThemeData(
            color: Colors.white,
          ),
      // title: setAppbar?.title ??
      //     Text(
      //       _conversationShowName,
      //       style: const TextStyle(
      //         color: Colors.white,
      //         fontSize: 17,
      //       ),
      //     ),
      title: TIMUIKitAppBarTitle(
        title: setAppbar?.title,
        conversationShowName: _conversationShowName,
        showC2cMessageEditStaus: widget.showC2cMessageEditStaus,
        fromUser: widget.conversationID,
      ),
      centerTitle: setAppbar?.centerTitle ?? true,
      leadingWidth: setAppbar?.leadingWidth ?? 70,
      leading: Selector<TUIChatGlobalModel, Tuple2<bool, int>>(
          builder: (context, data, _) {
            final isMultiSelect = data.item1;
            final unReadCount = data.item2;
            return isMultiSelect
                ? TextButton(
                    onPressed: () {
                      chatVM.updateMultiSelectStatus(false);
                    },
                    child: Text(
                      TIM_t('取消'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : setAppbar?.leading ??
                    Row(
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
                            chatVM.repliedMessage = null;
                            Navigator.pop(context);
                          },
                        ),
                        if (widget.showTotalUnReadCount && unReadCount > 0)
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.cautionColor,
                            ),
                            child: Text(_getTotalUnReadCount(unReadCount)),
                          ),
                      ],
                    );
          },
          shouldRebuild: (prev, next) =>
              prev.item1 != next.item1 || prev.item2 != next.item2,
          selector: (_, model) =>
              Tuple2(chatVM.isMultiSelect, model.totalUnReadCount)),
      actions: setAppbar?.actions,
    );
  }
}
