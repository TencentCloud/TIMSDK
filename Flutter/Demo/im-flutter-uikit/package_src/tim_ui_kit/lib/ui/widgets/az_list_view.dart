import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class AZListViewContainer extends StatefulWidget {
  final List<ISuspensionBeanImpl>? memberList;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? susItemBuilder;
  final bool isShowIndexBar;

  const AZListViewContainer(
      {Key? key,
      required this.memberList,
      required this.itemBuilder,
      this.isShowIndexBar = true,
      this.susItemBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AZListViewContainerState();
}

class _AZListViewContainerState extends State<AZListViewContainer> {
  List<ISuspensionBeanImpl>? _list;

  addShowSuspension(List<ISuspensionBeanImpl> curList) {
    for (int i = 0; i < curList.length; i++) {
      if (i == 0 || curList[i].tagIndex != curList[i - 1].tagIndex) {
        curList[i].isShowSuspension = true;
      }
    }
    return curList;
  }

  static Widget getSusItem(BuildContext context, String tag,
      {double susHeight = 40}) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16.0),
      color: theme.weakDividerColor,
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: true,
        style: TextStyle(
          fontSize: 14.0,
          color: theme.weakTextColor,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _list = addShowSuspension(widget.memberList!);
    });
  }

  @override
  void didUpdateWidget(covariant AZListViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _list = addShowSuspension(widget.memberList!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(
            builder: (context, tuiTheme, child) => AzListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                data: _list!,
                itemCount: _list!.length,
                itemBuilder: widget.itemBuilder,
                indexBarData: widget.isShowIndexBar
                    ? SuspensionUtil.getTagIndexList(_list!)
                        .where((element) => element != "@")
                        .toList()
                    : [],
                susItemBuilder: (BuildContext context, int index) {
                  if (widget.susItemBuilder != null) {
                    return widget.susItemBuilder!(context, index);
                  }
                  ISuspensionBeanImpl model = _list![index];
                  if (model.getSuspensionTag() == "@") {
                    return Container();
                  }
                  return getSusItem(context, model.getSuspensionTag());
                })));
  }
}

class ISuspensionBeanImpl<T> extends ISuspensionBean {
  String tagIndex;
  T memberInfo;
  ISuspensionBeanImpl({required this.tagIndex, required this.memberInfo});

  @override
  String getSuspensionTag() => tagIndex;
}
