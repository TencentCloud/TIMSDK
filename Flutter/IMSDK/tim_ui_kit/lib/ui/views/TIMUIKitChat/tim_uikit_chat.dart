// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_group_profile_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/frame.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_multi_select_panel.dart';

import 'TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'TIMUIKItMessageList/tim_uikit_history_message_list_container.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitChat extends StatefulWidget {
  int startTime = 0;
  int endTime = 0;

  /// conversation id, use for get history message list.
  final String conversationID;

  /// conversation type
  final int conversationType;

  /// use for show conversation name
  final String conversationShowName;

  /// avatar tap callback
  final void Function(String userID)? onTapAvatar;

  /// should show the nick name
  final bool showNickName;

  /// message item builder, can customizable partial message types or the layout for the whole line
  final MessageItemBuilder? messageItemBuilder;

  /// show unread message count, default value is false
  final bool showTotalUnReadCount;

  /// Deprecated("Please use [extraTipsActionItemBuilder] instead")
  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? exteraTipsActionItemBuilder;

  /// The builder for extra tips action
  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? extraTipsActionItemBuilder;

  /// show draft Text on TextField
  final String? draftText;

  /// jump to somewhere firstly
  final V2TimMessage? initFindingMsg;

  /// inputTextField hinttext
  final String? textFieldHintText;

  /// appbar config
  final AppBar? appBarConfig;

  /// main history list config
  final ListView? mainHistoryListConfig;

  /// more panel config and customize actions
  final MorePanelConfig? morePanelConfig;

  /// the builder for tongue on right bottom
  final TongueItemBuilder? tongueItemBuilder;

  final List<V2TimGroupAtInfo?>? groupAtInfoList;

  /// custom config for TIMUIKitChat widget
  final TIMUIKitChatConfig? config;

  /// jump to the page for `TIMUIKitGroupApplicationList` or other pages to deal with enter group application for group administrator manually, if you use [public group]. The parameter is `groupID`
  final ValueChanged<String>? onDealWithGroupApplication;

  /// the builder for abstract messages, normally used in replied message and forward message.
  final String Function(V2TimMessage message)? abstractMessageBuilder;

  /// tool tips panel configuration, long press message will show tool tips panel
  final ToolTipsConfig? toolTipsConfig;

  /// The life cycle for chat business logic
  final ChatLifeCycle? lifeCycle;

  /// custom emoji panel
  final Widget Function(
      {void Function() sendTextMessage,
      void Function(int index, String data) sendFaceMessage,
      void Function() deleteText,
      void Function(int unicode) addText})? customStickerPanel;

  TIMUIKitChat({
    Key? key,
    required this.conversationID,
    required this.conversationType,
    required this.conversationShowName,
    this.abstractMessageBuilder,
    this.onTapAvatar,
    this.showNickName = true,
    this.showTotalUnReadCount = false,
    this.messageItemBuilder,
    @Deprecated("Please use [extraTipsActionItemBuilder] instead")
        this.exteraTipsActionItemBuilder,
    this.extraTipsActionItemBuilder,
    this.draftText,
    this.textFieldHintText,
    this.initFindingMsg,
    this.appBarConfig,
    this.morePanelConfig,
    this.customStickerPanel,
    this.config = const TIMUIKitChatConfig(),
    this.tongueItemBuilder,
    this.groupAtInfoList,
    this.mainHistoryListConfig,
    this.onDealWithGroupApplication,
    this.toolTipsConfig,
    this.lifeCycle,
  }) : super(key: key) {
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  State<StatefulWidget> createState() => _TUIChatState();
}

class _TUIChatState extends TIMUIKitState<TIMUIKitChat> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
  final TUIGroupProfileViewModel groupProfileViewModel =
      serviceLocator<TUIGroupProfileViewModel>();
  final TIMUIKitInputTextFieldController textFieldController =
      TIMUIKitInputTextFieldController();

  late AutoScrollController autoController = AutoScrollController(
    viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
    axis: Axis.vertical,
  );

  @override
  void initState() {
    if (kProfileMode) {
      Frame.init();
    }
    model.initForEachConversation((String value) =>
        textFieldController.textEditingController?.text = value);
    model.markMessageAsRead(
        convID: widget.conversationID, convType: widget.conversationType);
    model.setChatConfig(widget.config!);
    model.abstractMessageBuilder = widget.abstractMessageBuilder;
    if (widget.conversationType == 2) {
      groupProfileViewModel.loadData(widget.conversationID);
      // groupProfileViewModel.setGroupListener();
    }
    model.lifeCycle = widget.lifeCycle;
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (kProfileMode) {
        widget.endTime = DateTime.now().millisecondsSinceEpoch;
        int timeSpend = widget.endTime - widget.startTime;
        print("Page render time:$timeSpend ms");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (kProfileMode) {
      Frame.destroy();
    }
    model.resetData();
    groupProfileViewModel.clearData();
  }

  Widget _renderJoinGroupApplication(int amount, TUITheme theme) {
    String option1 = amount.toString();
    return Container(
      height: 36,
      decoration: BoxDecoration(color: hexToColor("f6eabc")),
      child: GestureDetector(
        onTap: () {
          widget.onDealWithGroupApplication!(widget.conversationID);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              TIM_t_para("{{option1}} 条入群请求", "$option1 条入群请求")(
                  option1: option1),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 12),
              child: Text(
                TIM_t("去处理"),
                style: TextStyle(fontSize: 12, color: theme.primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final closePanel =
        OptimizeUtils.throttle((_) => textFieldController.hideAllPanel(), 60);

    return TIMUIKitChatProviderScope(
        conversationID: widget.conversationID,
        conversationType: widget.conversationType,
        providers: [
          Provider(create: (_) => widget.config),
        ],
        builder: (context, w) {
          final TUIChatViewModel model = Provider.of<TUIChatViewModel>(context);

          final isMultiSelect = model.isMultiSelect;

          List<V2TimGroupApplication> filteredApplicationList = [];
          if (widget.conversationType == 2 &&
              widget.onDealWithGroupApplication != null) {
            filteredApplicationList = model.groupApplicationList.where((item) {
              return (item.groupID == widget.conversationID) &&
                  item.handleStatus == 0;
            }).toList();
          }

          return GestureDetector(
            onTap: () {
              textFieldController.hideAllPanel();
            },
            child: Scaffold(
                appBar: TIMUIKitAppBar(
                  showTotalUnReadCount: widget.showTotalUnReadCount,
                  config: widget.appBarConfig,
                  conversationShowName: widget.conversationShowName,
                  conversationID: widget.conversationID,
                ),
                body: Column(
                  children: [
                    if (filteredApplicationList.isNotEmpty)
                      _renderJoinGroupApplication(
                          filteredApplicationList.length, theme),
                    Expanded(
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Listener(
                              onPointerMove: closePanel,
                              child: TIMUIKitHistoryMessageListContainer(
                                toolTipsConfig: widget.toolTipsConfig,
                                groupAtInfoList: widget.groupAtInfoList,
                                tongueItemBuilder: widget.tongueItemBuilder,
                                onLongPressForOthersHeadPortrait:
                                    (String? userId, String? nickName) {
                                  if (widget.conversationType != 1) {
                                    textFieldController.longPressToAt(
                                        nickName, userId);
                                  }
                                },
                                mainHistoryListConfig:
                                    widget.mainHistoryListConfig,
                                initFindingMsg: widget.initFindingMsg,
                                extraTipsActionItemBuilder:
                                    widget.extraTipsActionItemBuilder ??
                                        widget.exteraTipsActionItemBuilder,
                                conversationType: widget.conversationType,
                                scrollController: autoController,
                                onTapAvatar: widget.onTapAvatar,
                                showNickName: widget.showNickName,
                                messageItemBuilder: widget.messageItemBuilder,
                                conversationID: widget.conversationID,
                              ),
                            ))),
                    isMultiSelect
                        ? MultiSelectPanel(
                            conversationType: widget.conversationType,
                          )
                        : TIMUIKitInputTextField(
                            controller: textFieldController,
                            customStickerPanel: widget.customStickerPanel,
                            morePanelConfig: widget.morePanelConfig,
                            scrollController: autoController,
                            conversationID: widget.conversationID,
                            conversationType: widget.conversationType,
                            initText: widget.draftText,
                            hintText: widget.textFieldHintText,
                            showMorePannel:
                                widget.config?.isAllowShowMorePanel ?? true,
                            showSendAudio:
                                widget.config?.isAllowSoundMessage ?? true,
                            showSendEmoji:
                                widget.config?.isAllowEmojiPanel ?? true,
                          )
                  ],
                )),
          );
        });
  }
}

class TIMUIKitChatProviderScope extends StatelessWidget {
  static final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
  final TUIGroupProfileViewModel groupProfileViewModel =
      serviceLocator<TUIGroupProfileViewModel>();
  final Widget? child;
  final Widget Function(BuildContext, Widget?)? builder;
  final List<SingleChildWidget>? providers;

  /// conversation id, use for get history message list.
  final String conversationID;

  /// converastion type
  final int conversationType;

  TIMUIKitChatProviderScope(
      {Key? key,
      this.child,
      this.providers,
      this.builder,
      required this.conversationID,
      required this.conversationType})
      : super(key: key) {
    loadData();
  }

  loadData() {
    final convID = conversationID;
    final convType = conversationType;
    if (model.haveMoreData) {
      model.loadData(
        count: HistoryMessageDartConstant.getCount, //20
        userID: convType == 1 ? convID : null,
        groupID: convType == 2 ? convID : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: model),
        ChangeNotifierProvider.value(value: themeViewModel),
        ChangeNotifierProvider.value(value: groupProfileViewModel),
        Provider(create: (_) => const TIMUIKitChatConfig()),
        ...?providers
      ],
      child: child,
      builder: builder,
    );
  }
}
