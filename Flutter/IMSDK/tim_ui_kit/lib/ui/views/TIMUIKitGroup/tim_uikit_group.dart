import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/az_list_view.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

typedef GroupItemBuilder = Widget Function(
    BuildContext context, V2TimGroupInfo groupInfo);

class TIMUIKitGroup extends StatefulWidget {
  final void Function(V2TimGroupInfo groupInfo)? onTapItem;
  final Widget Function(BuildContext context)? emptyBuilder;
  final GroupItemBuilder? itemBuilder;

  /// the filter for group conversation
  final bool Function(V2TimGroupInfo? groupInfo)? groupCollector;

  const TIMUIKitGroup(
      {Key? key,
      this.onTapItem,
      this.emptyBuilder,
      this.itemBuilder,
      this.groupCollector})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitGroupState();
}

class _TIMUIKitGroupState extends TIMUIKitState<TIMUIKitGroup> {
  final TUIFriendShipViewModel _friendshipViewModel = serviceLocator<TUIFriendShipViewModel>();

  List<ISuspensionBeanImpl<V2TimGroupInfo>> _getShowList(
      List<V2TimGroupInfo> groupList) {
    final List<ISuspensionBeanImpl<V2TimGroupInfo>> showList =
        List.empty(growable: true);
    for (var i = 0; i < groupList.length; i++) {
      final item = groupList[i];

      final showName = item.groupName ?? item.groupID;
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

  Widget _itemBuilder(BuildContext context, V2TimGroupInfo groupInfo) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final showName = groupInfo.groupName ?? groupInfo.groupID;
    final faceUrl = groupInfo.faceUrl ?? "";
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 16),
      child: InkWell(
        onTap: (() {
          if (widget.onTapItem != null) {
            widget.onTapItem!(groupInfo);
          }
        }),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 12),
              margin: const EdgeInsets.only(right: 12),
              child: SizedBox(
                height: 40,
                width: 40,
                child: Avatar(faceUrl: faceUrl, showName: showName,type: 2,),
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
    );
  }

  GroupItemBuilder _getItemBuilder() {
    return widget.itemBuilder ?? _itemBuilder;
  }

  @override
  void initState() {
    super.initState();
    _friendshipViewModel.loadGroupListData();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _friendshipViewModel),
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
      ],
      builder: (BuildContext context, Widget? w) {
        List<V2TimGroupInfo> groupList =
            Provider.of<TUIFriendShipViewModel>(context).groupList;
        if (widget.groupCollector != null) {
          groupList = groupList.where(widget.groupCollector!).toList();
        }
        if (groupList.isNotEmpty) {
          final showList = _getShowList(groupList);
          return AZListViewContainer(
              isShowIndexBar: false,
              memberList: showList,
              itemBuilder: (context, index) {
                final groupInfo = showList[index].memberInfo;
                final itemBuilder = _getItemBuilder();
                return itemBuilder(context, groupInfo);
              });
        }

        if (widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        }

        return Container();
      },
    );
  }
}
