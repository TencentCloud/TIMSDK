import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/az_list_view.dart';

typedef GroupItemBuilder = Widget Function(
    BuildContext context, V2TimGroupInfo groupInfo);

class TIMUIKitGroup extends StatefulWidget {
  final void Function(V2TimGroupInfo groupInfo)? onTapItem;
  final Widget Function(BuildContext context)? emptyBuilder;
  final GroupItemBuilder? itemBuilder;

  /// 会话过滤器
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

class _TIMUIKitGroupState extends State<TIMUIKitGroup> {
  final TUIGroupViewModel _groupViewModel = TUIGroupViewModel();

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
    _groupViewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _groupViewModel),
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
      ],
      builder: (BuildContext context, Widget? w) {
        List<V2TimGroupInfo> groupList =
            Provider.of<TUIGroupViewModel>(context).groupList;
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
