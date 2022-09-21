// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/listener_model/tui_group_listener_model.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/frame.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_multi_select_panel.dart';

import 'TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'TIMUIKItMessageList/tim_uikit_chat_history_message_list_config.dart';
import 'TIMUIKItMessageList/tim_uikit_history_message_list_container.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitChat extends StatefulWidget {
  int startTime = 0;
  int endTime = 0;

  /// The chat controller you tend to used.
  /// You have to provide this before using it after tim_ui_kit 0.1.4.
  final TIMUIKitChatController? controller;

  /// The ID of the Group that the topic belongs to, only need for topic.
  final String? groupID;

  /// Conversation id, use for get history message list.
  final String conversationID;

  /// Conversation type.
  final ConvType conversationType;

  /// Use for show conversation name.
  final String conversationShowName;

  /// Avatar and name in message reaction tap callback.
  final void Function(String userID)? onTapAvatar;

  @Deprecated(
      "Nickname will not shows in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")

  /// Should show the nick name.
  final bool showNickName;

  /// Message item builder, can customize partial message item for different types or the layout for the whole line.
  final MessageItemBuilder? messageItemBuilder;

  /// Is show unread message count, default value is false
  final bool showTotalUnReadCount;

  /// Deprecated("Please use [extraTipsActionItemBuilder] instead")
  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? exteraTipsActionItemBuilder;

  /// The builder for extra tips action.
  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? extraTipsActionItemBuilder;

  /// The text of draft shows in TextField.
  /// [Recommend]: You can specify this field with the draftText from V2TimConversation.
  final String? draftText;

  /// The target message been jumped just after entering the chat page.
  final V2TimMessage? initFindingMsg;

  /// The hint text shows at input field.
  final String? textFieldHintText;

  /// The configuration for appbar.
  final AppBar? appBarConfig;

  /// The configuration for historical message list.
  final TIMUIKitHistoryMessageListConfig? mainHistoryListConfig;

  /// The configuration for more panel, can customize actions.
  final MorePanelConfig? morePanelConfig;

  /// The builder for the tongue on the right bottom.
  /// Used for back to bottom, shows the count of unread new messages,
  /// and prompts the messages that @ user.
  final TongueItemBuilder? tongueItemBuilder;

  /// The `groupAtInfoList` from `V2TimConversation`.
  final List<V2TimGroupAtInfo?>? groupAtInfoList;

  /// The configuration for the whole `TIMUIKitChat` widget.
  final TIMUIKitChatConfig? config;

  /// The callback for jumping to the page for `TIMUIKitGroupApplicationList` or other pages to deal with enter group application for group administrator manually, in the case of [public group].
  /// The parameter here is `String groupID`
  final ValueChanged<String>? onDealWithGroupApplication;

  /// The builder for abstract messages, normally used in replied message and forward message.
  final String Function(V2TimMessage message)? abstractMessageBuilder;

  /// The configuration for tool tips panel, long press messages will show this panel.
  final ToolTipsConfig? toolTipsConfig;

  /// The life cycle for chat business logic.
  final ChatLifeCycle? lifeCycle;

  /// The top fixed widget.
  final Widget? topFixWidget;

  /// Custom emoji panel.
  final Widget Function(
      {void Function() sendTextMessage,
      void Function(int index, String data) sendFaceMessage,
      void Function() deleteText,
      void Function(int unicode) addText})? customStickerPanel;

  TIMUIKitChat({
    Key? key,
    this.groupID,
    required this.conversationID,
    required this.conversationType,
    required this.conversationShowName,
    this.abstractMessageBuilder,
    this.onTapAvatar,
    @Deprecated("Nickname will not show in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
        this.showNickName = false,
    this.showTotalUnReadCount = false,
    this.messageItemBuilder,
    @Deprecated("Please use [extraTipsActionItemBuilder] instead")
        this.exteraTipsActionItemBuilder,
    this.extraTipsActionItemBuilder,
    this.draftText,
    this.textFieldHintText,
    this.initFindingMsg,
    this.appBarConfig,
    this.controller,
    this.morePanelConfig,
    this.customStickerPanel,
    this.config = const TIMUIKitChatConfig(),
    this.tongueItemBuilder,
    this.groupAtInfoList,
    this.mainHistoryListConfig,
    this.onDealWithGroupApplication,
    this.toolTipsConfig,
    this.lifeCycle,
    this.topFixWidget = const SizedBox(),
  }) : super(key: key) {
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  State<StatefulWidget> createState() => _TUIChatState();
}

class _TUIChatState extends TIMUIKitState<TIMUIKitChat> {
  final TUIChatSeparateViewModel model = TUIChatSeparateViewModel();
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
  final TIMUIKitInputTextFieldController textFieldController =
      TIMUIKitInputTextFieldController();

  late AutoScrollController autoController = AutoScrollController(
    viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
    axis: Axis.vertical,
  );

  @override
  void initState() {
    super.initState();
    if (kProfileMode) {
      Frame.init();
    }
    model.abstractMessageBuilder = widget.abstractMessageBuilder;
    model.onTapAvatar = widget.onTapAvatar;
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
    model.dispose();
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
        model: model,
        groupID: widget.groupID,
        textFieldController: textFieldController,
        conversationID: widget.conversationID,
        conversationType: widget.conversationType,
        lifeCycle: widget.lifeCycle,
        config: widget.config,
        providers: [
          Provider(create: (_) => widget.config),
        ],
        builder: (context, model, w) {
          final TUIChatGlobalModel chatGlobalModel =
              Provider.of<TUIChatGlobalModel>(context);
          final TUIChatSeparateViewModel model =
              Provider.of<TUIChatSeparateViewModel>(context);

          widget.controller?.model = model;
          final isMultiSelect = model.isMultiSelect;
          List<V2TimGroupApplication> filteredApplicationList = [];
          if (widget.conversationType == ConvType.group &&
              widget.onDealWithGroupApplication != null) {
            filteredApplicationList =
                chatGlobalModel.groupApplicationList.where((item) {
              return (item.groupID == widget.conversationID) &&
                  item.handleStatus == 0;
            }).toList();
          }

          final TUIGroupListenerModel groupListenerModel =
              Provider.of<TUIGroupListenerModel>(context);
          final NeedUpdate? needUpdate = groupListenerModel.needUpdate;
          if (needUpdate != null &&
              needUpdate.groupID == widget.conversationID) {
            groupListenerModel.needUpdate = null;
            switch (needUpdate.updateType) {
              case UpdateType.groupInfo:
                model.loadGroupInfo(widget.conversationID);
                break;
              case UpdateType.memberList:
                model.loadGroupMemberList(groupID: widget.conversationID);
                model.loadGroupInfo(widget.conversationID);
                break;
              default:
                break;
            }
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
                  showC2cMessageEditStaus:
                      widget.config?.showC2cMessageEditStaus ?? true,
                ),
                body: Column(
                  children: [
                    if (filteredApplicationList.isNotEmpty)
                      _renderJoinGroupApplication(
                          filteredApplicationList.length, theme),
                    widget.topFixWidget!,
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
                                  if (widget.conversationType != ConvType.c2c) {
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
                                // ignore: deprecated_member_use_from_same_package
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
                            model: model,
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
  final TUIChatGlobalModel globalModel = serviceLocator<TUIChatGlobalModel>();
  TUIChatSeparateViewModel? model;
  final TUIGroupListenerModel groupListenerModel =
      serviceLocator<TUIGroupListenerModel>();
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
  final Widget? child;

  /// You could get the model from here, and transfer it to other widget from TUIKit.
  final Widget Function(BuildContext, TUIChatSeparateViewModel, Widget?)
      builder;
  final List<SingleChildWidget>? providers;

  /// `TIMUIKitChatController` needs to be provided if you use it outside.
  final TIMUIKitChatController? controller;

  /// The global config for TIMUIKitChat.
  final TIMUIKitChatConfig? config;

  /// Conversation id, use for get history message list.
  final String conversationID;

  final String? groupID;

  /// Conversation type
  final ConvType conversationType;

  /// The life cycle for chat business logic.
  final ChatLifeCycle? lifeCycle;

  /// The controller for text field.
  final TIMUIKitInputTextFieldController? textFieldController;

  TIMUIKitChatProviderScope(
      {Key? key,
      this.child,
      this.providers,
      this.textFieldController,
      required this.builder,
      this.model,
      this.groupID,
      required this.conversationID,
      required this.conversationType,
      this.controller,
      this.config,
      this.lifeCycle})
      : super(key: key) {
    model ??= TUIChatSeparateViewModel();
    controller?.model = model;
    if (config != null) {
      model?.chatConfig = config!;
    }
    model?.lifeCycle = lifeCycle;
    model?.initForEachConversation(
      conversationType,
      conversationID,
      (String value) {
        textFieldController?.textEditingController?.text = value;
      },
      groupID: groupID,
    );
    model?.showC2cMessageEditStatus = (conversationType == ConvType.c2c
        ? config?.showC2cMessageEditStaus ?? true
        : false);
    loadData();
  }

  loadData() {
    if (model!.haveMoreData) {
      model!.loadData(
        count: HistoryMessageDartConstant.getCount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: model),
        ChangeNotifierProvider.value(value: globalModel),
        ChangeNotifierProvider.value(value: themeViewModel),
        ChangeNotifierProvider.value(value: groupListenerModel),
        Provider(create: (_) => const TIMUIKitChatConfig()),
        ...?providers
      ],
      child: child,
      builder: (context, w) => builder(context, model!, w),
    );
  }
}
