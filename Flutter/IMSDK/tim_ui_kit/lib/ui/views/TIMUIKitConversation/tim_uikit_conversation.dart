import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable_for_tencent_im/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/conversation_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_conversation_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_item.dart';
import 'package:tim_ui_kit/ui/widgets/customize_ball_pulse_header.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

typedef ConversationItemBuilder = Widget Function(
    V2TimConversation conversationItem,
    [V2TimUserStatus? onlineStatus]);

typedef ConversationItemSlidableBuilder = List<ConversationItemSlidablePanel>
    Function(V2TimConversation conversationItem);

class TIMUIKitConversation extends StatefulWidget {
  /// the callback after clicking conversation item
  final ValueChanged<V2TimConversation>? onTapItem;

  /// conversation controller
  final TIMUIKitConversationController? controller;

  /// the builder for conversation item
  final ConversationItemBuilder? itembuilder;

  /// the builder for slidable item for each conversation item
  final ConversationItemSlidableBuilder? itemSlidableBuilder;

  /// the widget shows when no conversation exists
  final Widget Function()? emptyBuilder;

  /// the filter for conversation
  final bool Function(V2TimConversation? conversation)? conversationCollector;

  /// the builder for the second line in each conservation item,
  /// usually shows the summary of the last message
  final LastMessageBuilder? lastMessageBuilder;

  /// The life cycle hooks for `TIMUIKitConversation`
  final ConversationLifeCycle? lifeCycle;

  /// Control if shows the online status for each user on its avatar.
  final bool isShowOnlineStatus;

  /// Control if shows the identifier that the conversation has a draft text, inputted in previous.
  /// Also, you have better specifying the `draftText` field for `TIMUIKitChat`, from the `draftText` in `V2TimConversation`,
  /// to meet the identifier shows here.
  final bool isShowDraft;

  const TIMUIKitConversation(
      {Key? key,
      this.lifeCycle,
      this.onTapItem,
      this.controller,
      this.itembuilder,
      this.isShowDraft = true,
      this.itemSlidableBuilder,
      this.conversationCollector,
      this.emptyBuilder,
      this.lastMessageBuilder,
      this.isShowOnlineStatus = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TIMUIKitConversationState();
  }
}

class ConversationItemSlidablePanel extends TIMUIKitStatelessWidget {
  ConversationItemSlidablePanel({
    Key? key,
    this.flex = 1,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.autoClose = true,
    required this.onPressed,
    this.icon,
    this.spacing = 4,
    this.label,
  })  : assert(flex > 0),
        assert(icon != null || label != null),
        super(key: key);

  /// {@macro slidable.actions.flex}
  final int flex;

  /// {@macro slidable.actions.backgroundColor}
  final Color backgroundColor;

  /// {@macro slidable.actions.foregroundColor}
  final Color? foregroundColor;

  /// {@macro slidable.actions.autoClose}
  final bool autoClose;

  /// {@macro slidable.actions.onPressed}
  final SlidableActionCallback? onPressed;

  /// An icon to display above the [label].
  final IconData? icon;

  /// The space between [icon] and [label] if both set.
  ///
  /// Defaults to 4.
  final double spacing;

  /// A label to display below the [icon].
  final String? label;

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return SlidableAction(
      onPressed: onPressed,
      flex: flex,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      autoClose: autoClose,
      label: label,
      spacing: spacing,
    );
  }
}

class _TIMUIKitConversationState extends TIMUIKitState<TIMUIKitConversation> {
  final TUIConversationViewModel model =
      serviceLocator<TUIConversationViewModel>();
  late TIMUIKitConversationController _timuiKitConversationController;
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
  final TUIFriendShipViewModel friendShipViewModel =
      serviceLocator<TUIFriendShipViewModel>();

  @override
  void initState() {
    super.initState();
    final controller = getController();
    _timuiKitConversationController = controller;
    _timuiKitConversationController.model = model;
    // _timuiKitConversationController.loadData();
  }

  TIMUIKitConversationController getController() {
    return widget.controller ?? TIMUIKitConversationController();
  }

  void onTapConvItem(V2TimConversation conversation) {
    if (widget.onTapItem != null) {
      widget.onTapItem!(conversation);
    }
    model.setSelectedConversation(conversation);
  }

  _clearHistory(V2TimConversation conversationItem) {
    _timuiKitConversationController.clearHistoryMessage(
        conversation: conversationItem);
  }

  _pinConversation(V2TimConversation conversation) {
    _timuiKitConversationController.pinConversation(
        conversationID: conversation.conversationID,
        isPinned: !conversation.isPinned!);
  }

  _deleteConversation(V2TimConversation conversation) {
    _timuiKitConversationController.deleteConversation(
        conversationID: conversation.conversationID);
  }

  List<ConversationItemSlidablePanel> _defaultSlidableBuilder(
    V2TimConversation conversationItem,
  ) {
    final theme = themeViewModel.theme;
    return [
      if (!PlatformUtils().isWeb)
        ConversationItemSlidablePanel(
          onPressed: (context) {
            _clearHistory(conversationItem);
          },
          backgroundColor: theme.primaryColor ?? CommonColor.primaryColor,
          foregroundColor: Colors.white,
          label: TIM_t("清除聊天"),
          spacing: 0,
          autoClose: true,
        ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _pinConversation(conversationItem);
        },
        backgroundColor: theme.infoColor ?? CommonColor.infoColor,
        foregroundColor: Colors.white,
        label: conversationItem.isPinned! ? TIM_t("取消置顶") : TIM_t("置顶"),
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _deleteConversation(conversationItem);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        label: TIM_t("删除"),
      )
    ];
  }

  ConversationItemSlidableBuilder _getSlidableBuilder() {
    return widget.itemSlidableBuilder ?? _defaultSlidableBuilder;
  }

  @override
  void dispose() {
    super.dispose();
    // model.dispose();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(value: friendShipViewModel)
        ],
        builder: (BuildContext context, Widget? w) {
          final _model = Provider.of<TUIConversationViewModel>(context);
          final _friendShipViewModel =
              Provider.of<TUIFriendShipViewModel>(context);
          _model.lifeCycle = widget.lifeCycle;
          List<V2TimConversation?> filteredConversationList = _model
              .conversationList
              .where((element) =>
                  (element?.groupID != null || element?.userID != null))
              .toList();
          bool haveMoreData = _model.haveMoreData;
          if (widget.conversationCollector != null) {
            filteredConversationList = filteredConversationList
                .where(widget.conversationCollector!)
                .toList();
          }

          return SlidableAutoCloseBehavior(
            child: EasyRefresh(
              header: CustomizeBallPulseHeader(color: theme.primaryColor),
              onRefresh: () async {
                model.refresh();
              },
              child: filteredConversationList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredConversationList.length,
                      itemBuilder: (context, index) {
                        if (index == filteredConversationList.length - 1) {
                          if (haveMoreData) {
                            _timuiKitConversationController.loadData();
                          }
                        }

                        final conversationItem =
                            filteredConversationList[index];

                        final V2TimUserStatus? onlineStatus =
                            _friendShipViewModel.userStatusList.firstWhere(
                                (item) =>
                                    item.userID == conversationItem?.userID,
                                orElse: () => V2TimUserStatus(statusType: 0));

                        if (widget.itembuilder != null) {
                          return widget.itembuilder!(
                              conversationItem!, onlineStatus);
                        }

                        final slidableChildren =
                            _getSlidableBuilder()(conversationItem!);
                        return Slidable(
                            groupTag: 'conversation-list',
                            child: InkWell(
                              child: TIMUIKitConversationItem(
                                  isShowDraft: widget.isShowDraft,
                                  lastMessageBuilder: widget.lastMessageBuilder,
                                  faceUrl: conversationItem.faceUrl ?? "",
                                  nickName: conversationItem.showName ?? "",
                                  isDisturb: conversationItem.recvOpt != 0,
                                  lastMsg: conversationItem.lastMessage,
                                  isPined: conversationItem.isPinned ?? false,
                                  groupAtInfoList:
                                      conversationItem.groupAtInfoList ?? [],
                                  unreadCount:
                                      conversationItem.unreadCount ?? 0,
                                  draftText: conversationItem.draftText,
                                  onlineStatus: (widget.isShowOnlineStatus &&
                                          conversationItem.userID != null &&
                                          conversationItem.userID!.isNotEmpty)
                                      ? onlineStatus
                                      : null,
                                  draftTimestamp:
                                      conversationItem.draftTimestamp,
                                  convType: conversationItem.type),
                              onTap: () => onTapConvItem(conversationItem),
                            ),
                            endActionPane: ActionPane(
                                extentRatio:
                                    slidableChildren.length > 2 ? 0.77 : 0.5,
                                motion: const DrawerMotion(),
                                children: slidableChildren));
                      })
                  : (widget.emptyBuilder != null
                      ? widget.emptyBuilder!()
                      : Container()),
            ),
          );
        });
  }
}
