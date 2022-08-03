import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/friend_list_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

export 'package:tim_ui_kit/ui/widgets/contact_list.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitContact extends StatefulWidget {
  /// the callback after clicking contact item
  final void Function(V2TimFriendInfo item)? onTapItem;

  /// the list on top
  final List<TopListItem>? topList;

  /// the builder for the list on top
  final Widget? Function(TopListItem item)? topListItemBuilder;

  /// the builder for the empty item, especially when there is no contact
  final Widget Function(BuildContext context)? emptyBuilder;

  /// the life cycle hooks for friend list or contacts list business logic
  final FriendListLifeCycle? lifeCycle;

  /// Control if shows the online status for each user on its avatar.
  final bool isShowOnlineStatus;

  const TIMUIKitContact(
      {Key? key,
      this.onTapItem,
      this.lifeCycle,
      this.topList,
      this.topListItemBuilder,
      this.emptyBuilder,
      this.isShowOnlineStatus = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitContactState();
}

class _TIMUIKitContactState extends TIMUIKitState<TIMUIKitContact> {
  final TUIFriendShipViewModel model = serviceLocator<TUIFriendShipViewModel>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
        ],
        builder: (context, w) {
          final model = Provider.of<TUIFriendShipViewModel>(context);
          model.contactListLifeCycle = widget.lifeCycle;
          final memberList = model.friendList ?? [];

          return (memberList.isEmpty && widget.emptyBuilder != null)
              ? widget.emptyBuilder!(context)
              : ContactList(
                  isShowOnlineStatus: widget.isShowOnlineStatus,
                  contactList: memberList,
                  onTapItem: widget.onTapItem,
                  topList: widget.topList,
                  topListItemBuilder: widget.topListItemBuilder,
                );
        });
  }
}
