import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/group_profile_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/group_profile_widget.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_profile_widget.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_button_area.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_manage.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_notification.dart';

export 'package:tim_ui_kit/ui/widgets/transimit_group_owner_select.dart';
export 'package:tim_ui_kit/ui/widgets/transimit_group_owner_select.dart';

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

typedef GroupProfileBuilder = Widget Function(BuildContext context,
    V2TimGroupInfo groupInfo, List<V2TimGroupMemberFullInfo?> groupMemberList);

class TIMUIKitGroupProfile extends StatefulWidget {
  /// Group ID
  final String groupID;
  final Color? backGroundColor;

  /// [Deprecated:] The builder for custom bottom operation area.
  /// [operationListBuilder] and [bottomOperationBuilder] merged into [builder], please use it instead.
  final Widget Function(BuildContext context, V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? bottomOperationBuilder;

  /// [Deprecated:] The builder for custom bottom operation area.
  /// [operationListBuilder] and [bottomOperationBuilder] merged into [builder], please use it instead.
  final Widget Function(BuildContext context, V2TimGroupInfo groupInfo,
      List<V2TimGroupMemberFullInfo?> groupMemberList)? operationListBuilder;

  /// [If you tend to customize the profile page, use [profileWidgetBuilder] with [profileWidgetsOrder] as priority.]
  /// The builder for each widgets in profile page,
  /// you can customize some of it by pass your own widget into here.
  /// Or, you can add your custom widget to the three custom widgets.
  final GroupProfileWidgetBuilder? profileWidgetBuilder;

  /// [If you tend to customize the profile page, use [profileWidgetBuilder] with [profileWidgetsOrder] as priority.]
  /// If the default widget order can not meet you needs,
  /// you may change the order by this array with widget enum.
  final List<GroupProfileWidgetEnum>? profileWidgetsOrder;

  /// The builder for the whole group profile page, you can use this to customize all the element here.
  /// Mentioned: If you use this builder, [profileWidgetBuilder] and [profileWidgetsOrder] will no longer works.
  final GroupProfileBuilder? builder;

  /// The life cycle hooks for group profile business logic.
  /// You have better to implement the `didLeaveGroup` in it.
  final GroupProfileLifeCycle? lifeCycle;

  const TIMUIKitGroupProfile(
      {Key? key,
      required this.groupID,
      this.backGroundColor,
      @Deprecated("[operationListBuilder] and [bottomOperationBuilder] merged into [builder], please use it instead")
          this.bottomOperationBuilder,
      @Deprecated("[operationListBuilder] and [bottomOperationBuilder] merged into [builder], please use it instead")
          this.operationListBuilder,
      this.builder,
      this.profileWidgetBuilder,
      this.profileWidgetsOrder,
      this.lifeCycle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitGroupProfileState();
}

class _TIMUIKitGroupProfileState extends TIMUIKitState<TIMUIKitGroupProfile> {
  final TUIGroupProfileViewModel _model =
      serviceLocator<TUIGroupProfileViewModel>();

  @override
  void initState() {
    super.initState();
    _model.loadData(widget.groupID);
    _model.lifeCycle = widget.lifeCycle;
    // _model.setGroupListener();
  }

  @override
  void dispose() {
    // _model.clearData();
    // _model.dispose();
    // _model.removeGroupListener();
    super.dispose();
  }

  final List<GroupProfileWidgetEnum> _defaultWidgetOrder = [
    GroupProfileWidgetEnum.detailCard,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.memberListTile,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.searchMessage,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.groupNotice,
    GroupProfileWidgetEnum.groupManage,
    GroupProfileWidgetEnum.groupJoiningModeBar,
    GroupProfileWidgetEnum.groupTypeBar,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.pinedConversationBar,
    GroupProfileWidgetEnum.muteGroupMessageBar,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.nameCardBar,
    GroupProfileWidgetEnum.operationDivider,
    GroupProfileWidgetEnum.buttonArea
  ];

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _model),
        ],
        builder: (context, w) {
          final groupInfo =
              Provider.of<TUIGroupProfileViewModel>(context).groupInfo;
          final memberList =
              Provider.of<TUIGroupProfileViewModel>(context).groupMemberList;
          if (groupInfo == null || memberList == null) {
            return Container();
          }

          final isGroupOwner = groupInfo.role ==
              GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER;
          final isAdmin = groupInfo.role ==
              GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;

          Widget groupProfilePage({required Widget child}) {
            return SharedDataWidget(
              model: _model,
              child: SingleChildScrollView(
                child: Container(
                  color: widget.backGroundColor ?? theme.weakBackgroundColor,
                  child: child,
                ),
              ),
            );
          }

          void toDefaultNoticePage() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupProfileNotificationPage(
                        model: _model,
                        notification: groupInfo.notification ?? "")));
          }

          void toDefaultManagePage() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupProfileGroupManagePage(
                          model: _model,
                        )));
          }

          List<Widget> _renderWidgetsWithOrder(
              List<GroupProfileWidgetEnum> order) {
            final GroupProfileWidgetBuilder? customBuilder =
                widget.profileWidgetBuilder;
            return order.map((element) {
              switch (element) {
                case GroupProfileWidgetEnum.detailCard:
                  return (customBuilder?.detailCard != null
                      ? customBuilder?.detailCard!(
                          groupInfo, _model.setGroupName)
                      : TIMUIKitGroupProfileWidget.detailCard(
                          groupInfo: groupInfo))!;
                case GroupProfileWidgetEnum.memberListTile:
                  return (customBuilder?.memberListTile != null
                      ? customBuilder?.memberListTile!(memberList)
                      : TIMUIKitGroupProfileWidget.memberTile())!;
                case GroupProfileWidgetEnum.groupNotice:
                  return (customBuilder?.groupNotice != null
                      ? customBuilder?.groupNotice!(
                          groupInfo.notification ?? "",
                          toDefaultNoticePage,
                          _model.setGroupNotification)
                      : TIMUIKitGroupProfileWidget.groupNotification())!;
                case GroupProfileWidgetEnum.groupManage:
                  if (isAdmin || isGroupOwner) {
                    return (customBuilder?.groupManage != null
                        ? customBuilder?.groupManage!(toDefaultManagePage)
                        : TIMUIKitGroupProfileWidget.groupManage())!;
                  } else {
                    return Container();
                  }
                case GroupProfileWidgetEnum.searchMessage:
                  return (customBuilder?.searchMessage != null
                      ? customBuilder?.searchMessage!()
                      : Text(TIM_t("你必须自定义search bar，并处理点击跳转")))!;
                case GroupProfileWidgetEnum.operationDivider:
                  return (customBuilder?.operationDivider != null
                      ? customBuilder?.operationDivider!()
                      : TIMUIKitGroupProfileWidget.operationDivider())!;
                case GroupProfileWidgetEnum.groupTypeBar:
                  return (customBuilder?.groupTypeBar != null
                      ? customBuilder?.groupTypeBar!(groupInfo.groupType)
                      : TIMUIKitGroupProfileWidget.groupType())!;
                case GroupProfileWidgetEnum.groupJoiningModeBar:
                  return (customBuilder?.groupJoiningModeBar != null
                      ? customBuilder?.groupJoiningModeBar!(
                          groupInfo.groupAddOpt ?? 1, _model.setGroupAddOpt)
                      : TIMUIKitGroupProfileWidget.groupAddOpt())!;
                case GroupProfileWidgetEnum.nameCardBar:
                  return (customBuilder?.nameCardBar != null
                      ? customBuilder?.nameCardBar!(
                          _model.getSelfNameCard(), _model.setNameCard)
                      : TIMUIKitGroupProfileWidget.nameCard())!;
                case GroupProfileWidgetEnum.muteGroupMessageBar:
                  return (customBuilder?.muteGroupMessageBar != null
                      ? customBuilder?.muteGroupMessageBar!(
                          _model.isDisturb ?? false, _model.setMessageDisturb)
                      : TIMUIKitGroupProfileWidget.messageDisturb())!;
                case GroupProfileWidgetEnum.pinedConversationBar:
                  return (customBuilder?.pinedConversationBar != null
                      ? customBuilder?.pinedConversationBar!(
                          _model.conversation?.isPinned ?? false,
                          _model.pinedConversation)
                      : TIMUIKitGroupProfileWidget.pinedConversation())!;
                case GroupProfileWidgetEnum.buttonArea:
                  return (customBuilder?.buttonArea != null
                      ? customBuilder?.buttonArea!(groupInfo, memberList)
                      : GroupProfileButtonArea(groupInfo.groupID, _model))!;
                case GroupProfileWidgetEnum.customBuilderOne:
                  return (customBuilder?.customBuilderOne != null
                      ? customBuilder?.customBuilderOne!(groupInfo, memberList)
                      // Please define the corresponding custom widget in `profileWidgetBuilder` before using it here.
                      : Text(TIM_t("如使用自定义区域，请在profileWidgetBuilder传入对应组件")))!;
                case GroupProfileWidgetEnum.customBuilderTwo:
                  return (customBuilder?.customBuilderTwo != null
                      ? customBuilder?.customBuilderTwo!(groupInfo, memberList)
                      // Please define the corresponding custom widget in `profileWidgetBuilder` before using it here.
                      : Text(TIM_t("如使用自定义区域，请在profileWidgetBuilder传入对应组件")))!;
                case GroupProfileWidgetEnum.customBuilderThree:
                  return (customBuilder?.customBuilderThree != null
                      ? customBuilder?.customBuilderThree!(
                          groupInfo, memberList)
                      // Please define the corresponding custom widget in `profileWidgetBuilder` before using it here.
                      : Text(TIM_t("如使用自定义区域，请在profileWidgetBuilder传入对应组件")))!;
                case GroupProfileWidgetEnum.customBuilderFour:
                  return (customBuilder?.customBuilderFour != null
                      ? customBuilder?.customBuilderFour!(groupInfo, memberList)
                      // Please define the corresponding custom widget in `profileWidgetBuilder` before using it here.
                      : Text(TIM_t("如使用自定义区域，请在profileWidgetBuilder传入对应组件")))!;
                case GroupProfileWidgetEnum.customBuilderFive:
                  return (customBuilder?.customBuilderFive != null
                      ? customBuilder?.customBuilderFive!(groupInfo, memberList)
                      // Please define the corresponding custom widget in `profileWidgetBuilder` before using it here.
                      : Text(TIM_t("如使用自定义区域，请在profileWidgetBuilder传入对应组件")))!;
                default:
                  return Container();
              }
            }).toList();
          }

          if (widget.builder != null) {
            return groupProfilePage(
              child: widget.builder!(context, groupInfo, memberList),
            );
          } else if (widget.profileWidgetsOrder != null) {
            return groupProfilePage(
              child: Column(
                children: [
                  ..._renderWidgetsWithOrder(widget.profileWidgetsOrder!)
                ],
              ),
            );
          } else {
            return groupProfilePage(
                child: Column(
              children: [..._renderWidgetsWithOrder(_defaultWidgetOrder)],
            ));
          }
        });
  }
}
