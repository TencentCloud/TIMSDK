import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_contact_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/az_list_view.dart';

class TIMUIKitContact extends StatefulWidget {
  /// tap联系人列表项回调
  final void Function(V2TimFriendInfo item)? onTapItem;

  /// 顶部列表
  final List<TopListItem>? topList;

  /// 顶部列表项构造器
  final Widget Function(TopListItem item)? topListItemBuilder;

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

  _getShowName(V2TimFriendInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.userProfile?.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  List<ISuspensionBeanImpl> _getShowList(List<V2TimFriendInfo> memberList) {
    final List<ISuspensionBeanImpl> showList = List.empty(growable: true);
    for (var i = 0; i < memberList.length; i++) {
      final item = memberList[i];
      final showName = _getShowName(item);
      String pinyin = PinyinHelper.getPinyinE(showName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (RegExp("[A-Z]").hasMatch(tag)) {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: tag));
      } else {
        showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: "#"));
      }
    }

    SuspensionUtil.sortListBySuspensionTag(showList);

    return showList;
  }

  Widget _buildItem(BuildContext context, V2TimFriendInfo item) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final showName = _getShowName(item);
    final faceUrl = item.userProfile?.faceUrl ?? "";

    return Container(
      padding: const EdgeInsets.only(top: 10, left: 16),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 12),
            child: Avatar(faceUrl: faceUrl, showName: showName),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 10, bottom: 19),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.weakDividerColor ??
                            CommonColor.weakDividerColor))),
            child: Text(
              showName,
              // textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          )),
        ],
      ),
    );
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

          // if (memberList.isEmpty) {
          //   if (widget.emptyBuilder != null) {
          //     return widget.emptyBuilder!(context);
          //   }
          //   return Container();
          // }

          final showList = _getShowList(memberList);

          if (widget.topList != null && widget.topList!.isNotEmpty) {
            final topList = widget.topList!
                .map((e) => ISuspensionBeanImpl(memberInfo: e, tagIndex: '@'))
                .toList();
            showList.insertAll(0, topList);
          }

          return AZListViewContainer(
            memberList: showList,
            itemBuilder: (context, index) {
              final memberInfo = showList[index].memberInfo;
              if (memberInfo is TopListItem) {
                if (widget.topListItemBuilder != null) {
                  return widget.topListItemBuilder!(memberInfo);
                }
              } else {
                return InkWell(
                  onTap: () {
                    if (widget.onTapItem != null) {
                      widget.onTapItem!(memberInfo);
                    }
                  },
                  child: _buildItem(context, memberInfo),
                );
              }
              return Container();
            },
          );
        });
  }
}

class TopListItem {
  final String name;
  final String id;
  TopListItem({required this.name, required this.id});
}
