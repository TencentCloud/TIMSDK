import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tuple/tuple.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// appbar config
  final AppBar? config;

  /// allow show conversation total unread count
  final bool showTotalUnReadCount;

  /// cnversation id
  final String conversationID;

  /// conversation name
  final String conversationShowName;
  const TIMUIKitAppBar(
      {Key? key,
      this.config,
      this.showTotalUnReadCount = true,
      this.conversationID = "",
      this.conversationShowName = ""})
      : super(key: key);

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
        final changedInfo = infoList.firstWhere(
          (element) => element.userID == widget.conversationID,
        );
        if (changedInfo.friendRemark != null) {
          _conversationShowName = changedInfo.friendRemark!;
          setState(() {});
        }
      },
    );
    if (_friendshipListener != null) {
      _friendshipServices.setFriendshipListener(listener: _friendshipListener!);
    }
  }

  _addGroupListener() {
    _groupListener = V2TimGroupListener(
      onGroupInfoChanged: (groupID, changeInfos) {
        if (groupID == widget.conversationID) {
          final groupNameChangeInfo = changeInfos.firstWhere((element) =>
              element.type ==
              GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME);
          if (groupNameChangeInfo.value != null) {
            _conversationShowName = groupNameChangeInfo.value!;
            setState(() {});
          }
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
    _addConversationShowNameListener();
    _addGroupListener();
  }

  @override
  void dispose() {
    super.dispose();
    _groupServices.removeGroupListener(listener: _groupListener);
    _friendshipServices.removeFriendListener(listener: _friendshipListener);
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final setAppbar = widget.config;
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
      title: setAppbar?.title ??
          Text(
            _conversationShowName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
      centerTitle: setAppbar?.centerTitle ?? true,
      leadingWidth: setAppbar?.leadingWidth ?? 70,
      leading: Selector<TUIChatViewModel, Tuple2<bool, int>>(
          builder: (context, data, _) {
            final isMultiSelect = data.item1;
            final unReadCount = data.item2;
            final chatVM =
                Provider.of<TUIChatViewModel>(context, listen: false);
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
                            chatVM.setRepliedMessage(null);
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
              Tuple2(model.isMultiSelect, model.totalUnReadCount)),
      actions: setAppbar?.actions,
    );
  }
}
