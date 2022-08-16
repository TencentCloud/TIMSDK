import 'package:flutter/material.dart';
import 'package:flutter_slidable_for_tencent_im/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/block_list_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

typedef BlackListItemBuilder = Widget Function(
    BuildContext context, V2TimFriendInfo friendInfo);

class TIMUIKitBlackList extends StatefulWidget {
  final void Function(V2TimFriendInfo friendInfo)? onTapItem;
  final Widget Function(BuildContext context)? emptyBuilder;
  final BlackListItemBuilder? itemBuilder;

  /// The life cycle hooks for block list business logic
  final BlockListLifeCycle? lifeCycle;

  const TIMUIKitBlackList(
      {Key? key,
      this.onTapItem,
      this.emptyBuilder,
      this.itemBuilder,
      this.lifeCycle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitBlackListState();
}

class _TIMUIKitBlackListState extends TIMUIKitState<TIMUIKitBlackList> {
  final TUIFriendShipViewModel _friendshipViewModel = serviceLocator<TUIFriendShipViewModel>();

  _getShowName(V2TimFriendInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.userProfile?.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  Widget _itemBuilder(BuildContext context, V2TimFriendInfo friendInfo) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final showName = _getShowName(friendInfo);
    final faceUrl = friendInfo.userProfile?.faceUrl ?? "";
    return Slidable(
        endActionPane: ActionPane(motion: const DrawerMotion(), children: [
          SlidableAction(
            onPressed: (context) async {
              await _friendshipViewModel.deleteFromBlockList([friendInfo.userID]);
            },
            backgroundColor: theme.cautionColor ?? CommonColor.cautionColor,
            foregroundColor: Colors.white,
            label: TIM_t("删除"),
            autoClose: true,
          )
        ]),
        child: GestureDetector(
          onTap: () {
            if(widget.onTapItem != null){
              widget.onTapItem!(friendInfo);
            }
          },
          child: Container(
            padding: const EdgeInsets.only(top: 10, left: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  margin: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Avatar(faceUrl: faceUrl, showName: showName),
                  ),
                ),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.weakDividerColor ??
                                      CommonColor.weakDividerColor))),
                      child: Text(
                        showName,
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }

  BlackListItemBuilder _getItemBuilder() {
    return widget.itemBuilder ?? _itemBuilder;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _friendshipViewModel),
      ],
      builder: (BuildContext context, Widget? w) {
        final model = Provider.of<TUIFriendShipViewModel>(context);
        model.blockListLifeCycle = widget.lifeCycle;
        final blockList = model.blockList;
        if (blockList.isNotEmpty) {
          return ListView.builder(
            itemCount: blockList.length,
            itemBuilder: (context, index) {
              final friendInfo = blockList[index];
              final itemBuilder = _getItemBuilder();
              return itemBuilder(context, friendInfo);
            },
          );
        }

        if (widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        }

        return Container();
      },
    );
  }
}
