// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/listener_model/tui_group_listener_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
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

  /// conversation id, use for get history message list.
  final String conversationID;

  /// conversation type
  final int conversationType;

  /// use for show conversation name
  final String conversationShowName;

  /// avatar and name in message reaction tap callback
  final void Function(String userID)? onTapAvatar;

  @Deprecated("Nickname will not shows in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
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
  final TIMUIKitHistoryMessageListConfig? mainHistoryListConfig;

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

  /// The top fixed widget
  final Widget? topFixWidget;

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
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final TIMUIKitInputTextFieldController textFieldController =
      TIMUIKitInputTextFieldController();
  V2TimGroupInfo? _groupInfo;
  String _groupMemberListSeq = "0";
  List<V2TimGroupMemberFullInfo?>? _groupMemberList = [];

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
    model.initForEachConversation(
        widget.conversationType,
        widget.conversationID,
        (String value) =>
            textFieldController.textEditingController?.text = value);
    model.markMessageAsRead(
        convID: widget.conversationID, convType: widget.conversationType);
    model.setChatConfig(widget.config!);
    model.abstractMessageBuilder = widget.abstractMessageBuilder;
    if (widget.conversationType == 2) {
      loadGroup();
    }
    model.onTapAvatar = widget.onTapAvatar;
    model.lifeCycle = widget.lifeCycle;
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (kProfileMode) {
        widget.endTime = DateTime.now().millisecondsSinceEpoch;
        int timeSpend = widget.endTime - widget.startTime;
        print("Page render time:$timeSpend ms");
      }
    });
    model.setShowC2cEditStatus(widget.conversationType == 1
        ? widget.config?.showC2cMessageEditStaus ?? true
        : false);
  }

  loadGroup() {
    _loadGroupInfo(widget.conversationID);
    _loadGroupMemberList(groupID: widget.conversationID);
  }

  Future<void> _loadGroupMemberList(
      {required String groupID, int count = 100, String? seq}) async {
    if (seq == null || seq == "" || seq == "0") {
      _groupMemberList = [];
    }
    final String? nextSeq = await _loadGroupMemberListFunction(
        groupID: groupID, seq: seq, count: count);
    if (nextSeq != null && nextSeq != "0" && nextSeq != "") {
      return await _loadGroupMemberList(
          groupID: groupID, count: count, seq: nextSeq);
    } else {
      setState(() {
        _groupMemberList = _groupMemberList;
        model.groupMemberList = _groupMemberList ?? [];
      });
    }
  }

  Future<String?> _loadGroupMemberListFunction(
      {required String groupID, int count = 100, String? seq}) async {
    if (seq == "0") {
      _groupMemberList?.clear();
    }
    final res = await _groupServices.getGroupMemberList(
        groupID: groupID,
        filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
        count: count,
        nextSeq: seq ?? _groupMemberListSeq);
    final groupMemberListRes = res.data;
    if (res.code == 0 && groupMemberListRes != null) {
      final groupMemberList = groupMemberListRes.memberInfoList ?? [];
      _groupMemberList = [...?_groupMemberList, ...groupMemberList];
      _groupMemberListSeq = groupMemberListRes.nextSeq ?? "0";
    }else if (res.code == 10010){
      model.isGroupExist = false;
    }else if(res.code == 10007){
      model.isNotAMember = true;
    }
    return groupMemberListRes?.nextSeq;
  }

  @override
  void dispose() {
    super.dispose();
    if (kProfileMode) {
      Frame.destroy();
    }
    model.resetData();
  }

  _loadGroupInfo(String groupID) async {
    final groupInfo = await _groupServices
        .getGroupsInfo(groupIDList: [widget.conversationID]);
    if (groupInfo != null) {
      final groupRes = groupInfo.first;
      if (groupRes.resultCode == 0) {
        setState(() {
          _groupInfo = groupRes.groupInfo;
        });
      }
    }
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
          final TUIGroupListenerModel groupListenerModel = Provider.of<TUIGroupListenerModel>(context);
          final NeedUpdate? needUpdate = groupListenerModel.needUpdate;
          if(needUpdate != null && needUpdate.groupID == widget.conversationID){
            groupListenerModel.needUpdate = null;
            loadGroup();
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
                  showC2cMessageEditStaus: widget.config?.showC2cMessageEditStaus ?? true,
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
                            groupInfo: _groupInfo,
                            groupMemberList: _groupMemberList,
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
  final TUIGroupListenerModel groupListenerModel =
  serviceLocator<TUIGroupListenerModel>();
  final TUIThemeViewModel themeViewModel = serviceLocator<TUIThemeViewModel>();
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
        ChangeNotifierProvider.value(value: groupListenerModel),
        Provider(create: (_) => const TIMUIKitChatConfig()),
        ...?providers
      ],
      child: child,
      builder: builder,
    );
  }
}
