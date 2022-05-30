// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_black_list_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

typedef BlackListItemBuilder = Widget Function(
    BuildContext context, V2TimFriendInfo groupInfo);

class TIMUIKitBlackList extends StatefulWidget {
  final void Function(V2TimFriendInfo groupInfo)? onTapItem;
  final Widget Function(BuildContext context)? emptyBuilder;
  final BlackListItemBuilder? itemBuilder;

  const TIMUIKitBlackList(
      {Key? key, this.onTapItem, this.emptyBuilder, this.itemBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitBlackListState();
}

class _TIMUIKitBlackListState extends State<TIMUIKitBlackList> {
  final TUIBlackListViewModel _blackListViewModel = TUIBlackListViewModel();

  _getShowName(V2TimFriendInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.userProfile?.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  Widget _itemBuilder(BuildContext context, V2TimFriendInfo groupInfo) {
    final I18nUtils ttBuild = I18nUtils(context);
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final showName = _getShowName(groupInfo);
    final faceUrl = groupInfo.userProfile?.faceUrl ?? "";
    return Slidable(
        endActionPane: ActionPane(motion: const DrawerMotion(), children: [
          SlidableAction(
            onPressed: (context) async {
              await _blackListViewModel.deleteFromBlackList([groupInfo.userID]);
              _blackListViewModel.loadData();
            },
            backgroundColor: theme.cautionColor ?? CommonColor.cautionColor,
            foregroundColor: Colors.white,
            label: ttBuild.imt("删除"),
            autoClose: true,
          )
        ]),
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
        ));
  }

  BlackListItemBuilder _getItemBuilder() {
    return widget.itemBuilder ?? _itemBuilder;
  }

  @override
  void initState() {
    super.initState();
    _blackListViewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _blackListViewModel),
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
      ],
      builder: (BuildContext context, Widget? w) {
        final blackList = Provider.of<TUIBlackListViewModel>(context).blackList;
        if (blackList.isNotEmpty) {
          return ListView.builder(
            itemCount: blackList.length,
            itemBuilder: (context, index) {
              final friendInfo = blackList[index];
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
