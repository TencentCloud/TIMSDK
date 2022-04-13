import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_contact_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

export 'package:tim_ui_kit/ui/widgets/contact_list.dart';

class TIMUIKitContact extends StatefulWidget {
  /// tap联系人列表项回调
  final void Function(V2TimFriendInfo item)? onTapItem;

  /// 顶部列表
  final List<TopListItem>? topList;

  /// 顶部列表项构造器
  final Widget? Function(TopListItem item)? topListItemBuilder;

  /// 联系人为空时显示
  final Widget Function(BuildContext context)? emptyBuilder;

  const TIMUIKitContact(
      {Key? key,
      this.onTapItem,
      this.topList,
      this.topListItemBuilder,
      this.emptyBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitContactState();
}

class _TIMUIKitContactState extends State<TIMUIKitContact> {
  final TUIContactViewModel model = serviceLocator<TUIContactViewModel>();

  @override
  void initState() {
    super.initState();
    model.loadData();
    model.setFriendshipListener();
  }

  @override
  void dispose() {
    super.dispose();
    model.removeFriendShipListener();
    // model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final memberList =
              Provider.of<TUIContactViewModel>(context).friendList ?? [];

          return ContactList(
            contactList: memberList,
            onTapItem: widget.onTapItem,
            topList: widget.topList,
            topListItemBuilder: widget.topListItemBuilder,
          );
        });
  }
}
