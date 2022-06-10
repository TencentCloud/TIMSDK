import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_conversation_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_item.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/widgets/customize_ball_pulse_header.dart';

typedef ConversationItemBuilder = Widget Function(
    V2TimConversation conversationItem);

typedef ConversationItemSlidableBuilder = List<ConversationItemSlidablePanel>
    Function(V2TimConversation conversationItem);

class TIMUIKitConversation extends StatefulWidget {
  /// the callback after clicking contact item
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

  /// the builder for the second line in each conservation item, usually shows the summary of the last message
  final LastMessageBuilder? lastMessageBuilder;

  const TIMUIKitConversation(
      {Key? key,
      this.onTapItem,
      this.controller,
      this.itembuilder,
      this.itemSlidableBuilder,
      this.conversationCollector,
      this.emptyBuilder,
      this.lastMessageBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TIMUIKitConversationState();
  }
}

class ConversationItemSlidablePanel extends StatelessWidget {
  const ConversationItemSlidablePanel({
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
  Widget build(BuildContext context) {
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

class _TIMUIKitConversationState extends State<TIMUIKitConversation> {
  late TUIConversationViewModel model;
  late TIMUIKitConversationController _timuiKitConversationController;
  final TUIThemeViewModel _themeViewModel = serviceLocator<TUIThemeViewModel>();

  @override
  void initState() {
    super.initState();
    final controller = getController();
    model = controller.model;
    _timuiKitConversationController = controller;
    _timuiKitConversationController.loadData();
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
    final theme = _themeViewModel.theme;
    final I18nUtils ttBuild = I18nUtils(context);
    return [
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _clearHistory(conversationItem);
        },
        backgroundColor: theme.primaryColor ?? CommonColor.primaryColor,
        foregroundColor: Colors.white,
        label: ttBuild.imt("清除聊天"),
        spacing: 0,
        autoClose: true,
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _pinConversation(conversationItem);
        },
        backgroundColor: theme.infoColor ?? CommonColor.infoColor,
        foregroundColor: Colors.white,
        label: conversationItem.isPinned!
            ? ttBuild.imt("取消置顶")
            : ttBuild.imt("置顶"),
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _deleteConversation(conversationItem);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        label: ttBuild.imt("删除"),
      )
    ];
  }

  ConversationItemSlidableBuilder _getSlidableBuilder() {
    return widget.itemSlidableBuilder ?? _defaultSlidableBuilder;
  }

  @override
  void dispose() {
    super.dispose();
    model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(value: _themeViewModel)
        ],
        builder: (BuildContext context, Widget? w) {
          final _model = Provider.of<TUIConversationViewModel>(context);
          // final theme = _themeViewModel.theme;
          List<V2TimConversation?> filteredConversationList =
              _model.conversationList;
          bool haveMoreData = _model.haveMoreData;
          if (widget.conversationCollector != null) {
            filteredConversationList = filteredConversationList
                .where(widget.conversationCollector!)
                .toList();
          }
          return SlidableAutoCloseBehavior(
            child: EasyRefresh(
              header: CustomizeBallPulseHeader(
                  color: _themeViewModel.theme.primaryColor),
              onRefresh: () async {
                model.clear();
                model.loadData(count: 100);
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
                        if (widget.itembuilder != null) {
                          return widget.itembuilder!(conversationItem!);
                        }

                        final slidableChildren =
                            _getSlidableBuilder()(conversationItem!);
                        return Slidable(
                            groupTag: 'conversation-list',
                            child: InkWell(
                              child: TIMUIKitConversationItem(
                                lastMessageBuilder: widget.lastMessageBuilder,
                                faceUrl: conversationItem.faceUrl ?? "",
                                nickName: conversationItem.showName ?? "",
                                isDisturb: conversationItem.recvOpt != 0,
                                lastMsg: conversationItem.lastMessage,
                                isPined: conversationItem.isPinned ?? false,
                                groupAtInfoList:
                                    conversationItem.groupAtInfoList ?? [],
                                unreadCount: conversationItem.unreadCount ?? 0,
                                draftText: conversationItem.draftText,
                                draftTimestamp: conversationItem.draftTimestamp,
                              ),
                              onTap: () => onTapConvItem(conversationItem),
                            ),
                            endActionPane: ActionPane(
                                extentRatio:
                                    slidableChildren.length > 2 ? 0.7 : 0.5,
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
