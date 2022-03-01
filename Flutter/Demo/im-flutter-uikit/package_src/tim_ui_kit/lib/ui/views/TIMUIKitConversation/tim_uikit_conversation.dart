import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_conversation_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation_item.dart';

import '../../../i18n/i18n_utils.dart';

typedef ConversationItemBuilder = Widget Function(
    V2TimConversation conversationItem);

typedef ConversationItemSlidableBuilder = List<ConversationItemSlidablePanel>
    Function(V2TimConversation conversationItem);

class TIMUIKitConversation extends StatefulWidget {
  /// tap 会话条目的回调
  final ValueChanged<V2TimConversation>? onTapItem;

  final TIMUIKitConversationController? controller;

  /// 会话条目构造器
  final ConversationItemBuilder? itembuilder;

  /// 会话条目滑动块儿构造器
  final ConversationItemSlidableBuilder? itemSlidableBuilder;

  /// 会话为空时展示
  final Widget Function()? emptyBuilder;

  /// 会话过滤器
  final bool Function(V2TimConversation? conversation)? conversationCollector;

  const TIMUIKitConversation(
      {Key? key,
      this.onTapItem,
      this.controller,
      this.itembuilder,
      this.itemSlidableBuilder,
      this.conversationCollector,
      this.emptyBuilder})
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

  List<ConversationItemSlidablePanel> _defaultSlidableBuilder(
      V2TimConversation conversationItem) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
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
        label: conversationItem.isPinned! ? ttBuild.imt("取消置顶") : ttBuild.imt("置顶"),
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
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (BuildContext context, Widget? w) {
          List<V2TimConversation?> filteredConversationList =
              Provider.of<TUIConversationViewModel>(context).conversationList;
          if (widget.conversationCollector != null) {
            filteredConversationList = filteredConversationList
                .where(widget.conversationCollector!)
                .toList();
          }
          if (filteredConversationList.isEmpty) {
            if (widget.emptyBuilder != null) {
              return widget.emptyBuilder!();
            }
          }
          return ListView.builder(
              itemCount: filteredConversationList.length,
              itemBuilder: (context, index) {
                final conversationItem = filteredConversationList[index];
                if (widget.itembuilder != null) {
                  return widget.itembuilder!(conversationItem!);
                }

                return Slidable(
                    child: InkWell(
                      child: TIMUIKitConversationItem(
                          faceUrl: conversationItem!.faceUrl ?? "",
                          nickName: conversationItem.showName ?? "",
                          lastMsg: conversationItem.lastMessage,
                          isPined: conversationItem.isPinned ?? false,
                          groupAtInfoList:
                              conversationItem.groupAtInfoList ?? [],
                          unreadCount: conversationItem.unreadCount ?? 0),
                      onTap: () => onTapConvItem(conversationItem),
                    ),
                    endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: _getSlidableBuilder()(conversationItem)));
              });
        });
  }
}
