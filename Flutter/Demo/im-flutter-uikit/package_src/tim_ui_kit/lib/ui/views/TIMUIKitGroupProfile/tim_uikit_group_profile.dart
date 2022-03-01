import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_add_opt.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_detai_card.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_manage.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_member_tile.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_name_card.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_notification.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_type.dart';

class SharedDataWidget extends InheritedWidget {
  final TUIGroupProfileViewModel model;

  const SharedDataWidget({Key? key, required Widget child, required this.model})
      : super(key: key, child: child);

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static SharedDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SharedDataWidget>();
  }

  @override
  bool updateShouldNotify(covariant SharedDataWidget oldWidget) {
    return oldWidget.model != model;
  }
}

class TIMUIKitGroupProfile extends StatefulWidget {
  /// 群ID
  final String groupID;
  final Color? backGroundColor;

  /// 用于自定义构造操作条目
  final Widget Function(BuildContext context)? bottomOperationBuilder;

  /// 用于自定义构造底部操作条目
  final Widget Function(BuildContext context, V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? operationListBuilder;

  const TIMUIKitGroupProfile({
    Key? key,
    required this.groupID,
    this.backGroundColor,
    this.bottomOperationBuilder,
    this.operationListBuilder,
  }) : super(key: key);

  static Widget detailCard(
      {required V2TimGroupInfo groupInfo,
      required Function(String updateGroupName) updateGroupName}) {
    return GroupProfileDetailCard(
      groupInfo: groupInfo,
      updateGroupName: updateGroupName,
    );
  }

  static Widget memberTile() {
    return const GroupMemberTile();
  }

  static Widget groupNotification() {
    return const GroupProfileNotification();
  }

  static Widget groupManage() {
    return const GroupProfileGroupManage();
  }

  static Widget operationDivider() {
    return const SizedBox(
      height: 10,
    );
  }

  static Widget groupType() {
    return const GroupProfileType();
  }

  static Widget groupAddOpt() {
    return const GroupProfileAddOpt();
  }

  static Widget nameCard() {
    return GroupProfileNameCard();
  }

  @override
  State<StatefulWidget> createState() => _TIMUIKitGroupProfileState();
}

class _TIMUIKitGroupProfileState extends State<TIMUIKitGroupProfile> {
  final TUIGroupProfileViewModel _model = TUIGroupProfileViewModel();

  @override
  void initState() {
    super.initState();
    _model.loadData(widget.groupID);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _defaultOperationBuilder() {
    return Column(children: [
      TIMUIKitGroupProfile.memberTile(),
      TIMUIKitGroupProfile.operationDivider(),
      TIMUIKitGroupProfile.groupNotification(),
      TIMUIKitGroupProfile.groupManage(),
      TIMUIKitGroupProfile.groupAddOpt(),
      TIMUIKitGroupProfile.groupType(),
      TIMUIKitGroupProfile.operationDivider(),
      TIMUIKitGroupProfile.nameCard()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final groupInfo =
              Provider.of<TUIGroupProfileViewModel>(context).groupInfo;
          final memberList =
              Provider.of<TUIGroupProfileViewModel>(context).groupMemberList;
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          if (groupInfo == null || memberList == null) {
            return Container();
          }
          return SharedDataWidget(
            model: _model,
            child: SingleChildScrollView(
              child: Container(
                color: widget.backGroundColor ?? theme.weakBackgroundColor,
                child: Column(
                  children: [
                    TIMUIKitGroupProfile.detailCard(
                        groupInfo: groupInfo,
                        updateGroupName: (groupName) async {
                          final res = await _model.setGroupName(groupName);
                          if (res != null && res.code != 0) {
                            Fluttertoast.showToast(
                              msg: res.desc,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.white,
                              backgroundColor: Colors.black,
                            );
                          }
                        }),
                    widget.operationListBuilder != null
                        ? widget.operationListBuilder!(
                            context, groupInfo, memberList)
                        : _defaultOperationBuilder(),
                    if (widget.bottomOperationBuilder != null)
                      widget.bottomOperationBuilder!(context)
                  ],
                ),
              ),
            ),
          );
        });
  }
}
