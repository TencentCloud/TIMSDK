import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_location_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/shared_theme.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_more_panel.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_text_field.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_multi_select_panel.dart';

class TIMUIKitChat extends StatefulWidget {
  /// conversation id, use for get history message list.
  final String conversationID;

  /// converastion type
  final int conversationType;

  /// use for show conversation name
  final String conversationShowName;

  /// avatar tap callback
  final void Function(String userID)? onTapAvatar;

  /// should show the nick name
  final bool showNickName;

  /// message item builder
  final Widget? Function(V2TimMessage message)? messageItemBuilder;

  /// show unread message count, default value is false
  final bool showTotalUnReadCount;

  final Widget? Function(V2TimMessage message, Function() closeTooltip, [Key? key])?
      exteraTipsActionItemBuilder;

  /// show draft Text on TextField
  final String? draftText;

  /// jump to somewhere firstly
  final int? initFindingTimestamp;

  /// inputTextField hinttext
  final String? textFieldHintText;

  /// appbar config
  final AppBar? appBarConfig;

  /// more pannel config and customize actions
  final MorePanelConfig? morePanelConfig;

  /// location message item builder
  final Widget? Function(
    V2TimLocationElem locationElem,
    bool isFromSelf,
    bool isShowJump,
    VoidCallback clearJump,
    String? messageID,
  )? locationMessageItemBuilder;

  /// custom config for TIMUIKitChat widget
  final TIMUIKitChatConfig? config;

  /// custom emoji panel
  final Widget Function(
      {void Function() sendTextMessage,
      void Function(int index, String data) sendFaceMessage,
      void Function() deleteText,
      void Function(int unicode) addText})? customStickerPanel;

  const TIMUIKitChat(
      {Key? key,
      required this.conversationID,
      required this.conversationType,
      this.onTapAvatar,
      this.showNickName = true,
      this.showTotalUnReadCount = false,
      required this.conversationShowName,
      this.messageItemBuilder,
      this.exteraTipsActionItemBuilder,
      this.draftText,
      this.textFieldHintText,
      this.initFindingTimestamp,
      this.appBarConfig,
      this.morePanelConfig,
      this.customStickerPanel,
      this.locationMessageItemBuilder,
      this.config = const TIMUIKitChatConfig()})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TUIChatState();
}

class _TUIChatState extends State<TIMUIKitChat> {
  GlobalKey<dynamic> inputextField = GlobalKey();

  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final ScrollController listViewScrollContoler = ScrollController();
  late AutoScrollController autoController = AutoScrollController(
    viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
    axis: Axis.vertical,
  );
  bool closeKeyboardPanel = false;

  @override
  void initState() {
    if (widget.conversationType == 2) {
      model.addGroupListener();
    } else {
      model.addFriendInfoChangeListener();
    }
    retriveData(null);
    model.markMessageAsRead(
        convID: widget.conversationID, convType: widget.conversationType);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.conversationType == 2) {
      model.removeGroupListener();
    } else {
      model.removeFriendChangeListener();
    }
  }

  void retriveData(String? lastMsgID, [int? count]) {
    final convID = widget.conversationID;
    final convType = widget.conversationType;
    model.loadData(
        conversationShowName: widget.conversationShowName,
        count: count ?? HistoryMessageDartConstant.getCount, //20
        userID: convType == 1 ? convID : null,
        groupID: convType == 2 ? convID : null,
        lastMsgID: lastMsgID);
  }

  Future<void> retriveDataAsync(String? lastMsgID, [int? count]) async {
    final convID = widget.conversationID;
    final convType = widget.conversationType;
    await model.loadData(
        count: count ?? HistoryMessageDartConstant.getCount, //20
        userID: convType == 1 ? convID : null,
        groupID: convType == 2 ? convID : null,
        lastMsgID: lastMsgID);
    return;
  }

  String _getTotalUnReadCount(int unreadCount) {
    return unreadCount < 99 ? unreadCount.toString() : "99";
  }

  _onMsgSendFailIconTap(V2TimMessage message) {
    final convID = widget.conversationID;
    final convType =
        widget.conversationType == 1 ? ConvType.c2c : ConvType.group;
    MessageUtils.handleMessageError(
        model.reSendFailMessage(
            message: message, convType: convType, convID: convID),
        context);
  }

  _checkPermissions() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Permissions.checkPermission(context, Permission.storage.value);
      Permissions.checkPermission(context, Permission.microphone.value);
      Permissions.checkPermission(context, Permission.photos.value);
      Permissions.checkPermission(context, Permission.camera.value);
    });
  }

  AppBar _getAppbarConfig(TUITheme theme, int totalUnreadCount) {
    final setAppbar = widget.appBarConfig;
    final I18nUtils ttBuild = I18nUtils(context);
    return AppBar(
      backgroundColor: setAppbar?.backgroundColor,
      actionsIconTheme: setAppbar?.actionsIconTheme,
      foregroundColor: setAppbar?.foregroundColor,
      elevation: setAppbar?.elevation,
      bottom: setAppbar?.bottom,
      bottomOpacity: setAppbar?.bottomOpacity ?? 1.0,
      titleSpacing: setAppbar?.titleSpacing,
      automaticallyImplyLeading: setAppbar?.automaticallyImplyLeading ?? false,
      shadowColor: setAppbar?.shadowColor ?? theme.weakDividerColor,
      excludeHeaderSemantics: setAppbar?.excludeHeaderSemantics ?? false,
      toolbarHeight: setAppbar?.toolbarHeight,
      titleTextStyle: setAppbar?.titleTextStyle,
      toolbarOpacity: setAppbar?.toolbarOpacity ?? 1.0,
      toolbarTextStyle: setAppbar?.toolbarTextStyle,
      flexibleSpace: setAppbar?.flexibleSpace ??
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
      iconTheme: setAppbar?.iconTheme ??
          const IconThemeData(
            color: Colors.white,
          ),
      title: setAppbar?.title ??
          Text(
            model.conversationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
      centerTitle: setAppbar?.centerTitle ?? true,
      leadingWidth: setAppbar?.leadingWidth,
      leading: model.isMultiSelect
          ? TextButton(
              onPressed: () {
                model.updateMultiSelectStatus(false);
              },
              child: Text(
                ttBuild.imt('取消'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          : setAppbar?.leading ??
              Row(
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(left: 16),
                    constraints: const BoxConstraints(),
                    icon: Image.asset(
                      'images/arrow_back.png',
                      package: 'tim_ui_kit',
                      height: 34,
                      width: 34,
                    ),
                    onPressed: () async {
                      model.setRepliedMessage(null);
                      Navigator.pop(context);
                    },
                  ),
                  if (widget.showTotalUnReadCount && totalUnreadCount > 0)
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.cautionColor,
                      ),
                      child: Text(_getTotalUnReadCount(totalUnreadCount)),
                    ),
                ],
              ),
      actions: setAppbar?.actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkPermissions();
    final closePanel = OptimizeUtils.throttle(
        (_) => inputextField.currentState.hideAllPanel(), 60);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>()),
          Provider.value(
            value: widget.config,
          )
        ],
        builder: (context, w) {
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          return SharedThemeWidget(
              theme: theme,
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  // 点击屏幕时，关闭所有Panel
                  inputextField.currentState.hideAllPanel();

                  setState(() {
                    closeKeyboardPanel = true;
                  });
                },
                child: Consumer<TUIChatViewModel>(
                  builder: (context, value, child) {
                    return Scaffold(
                      resizeToAvoidBottomInset: false,
                      appBar: _getAppbarConfig(theme, value.totalUnReadCount),
                      body: Column(
                        children: [
                          Expanded(
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Listener(
                                    onPointerMove: closePanel,
                                    child: TIMUIKitHistoryMessageList(
                                        locationMessageItemBuilder:
                                            widget.locationMessageItemBuilder,
                                        onLongPressForOthersHeadPortrait:
                                            (String? userId, String? nickName) {
                                          widget.conversationType == 1
                                              ? ConvType.c2c
                                              : inputextField.currentState
                                                  .longPressToAt(
                                                      userId, nickName);
                                        },
                                        initFindingTimestamp:
                                            widget.initFindingTimestamp,
                                        exteraTipsActionItemBuilder:
                                            widget.exteraTipsActionItemBuilder,
                                        conversationType:
                                            widget.conversationType,
                                        messageList:
                                            model.getMessageListByConvId(
                                                    widget.conversationID) ??
                                                [],
                                        updateJumpTimestamp: (timestamp) =>
                                            model.jumpTimestamp = timestamp,
                                        loadMore: retriveData,
                                        loadMoreAsync: retriveDataAsync,
                                        scrollController: autoController,
                                        isNoMoreMessage: !model.haveMoreData,
                                        onTapAvatar: widget.onTapAvatar,
                                        isShowNickName: widget.showNickName,
                                        messageItemBuilder:
                                            widget.messageItemBuilder,
                                        onMsgSendFailIconTap:
                                            _onMsgSendFailIconTap),
                                  ))),
                          model.isMultiSelect
                              ? MultiSelectPanel(
                                  conversationShowName: model.conversationName,
                                  conversationType: widget.conversationType,
                                )
                              : InputTextField(
                                  customStickerPanel: widget.customStickerPanel,
                                  morePanelConfig: widget.morePanelConfig,
                                  scrollController: autoController,
                                  conversationID: widget.conversationID,
                                  conversationType: widget.conversationType,
                                  listViewController: listViewScrollContoler,
                                  closeKeyboardPanel: closeKeyboardPanel,
                                  draftText: widget.draftText,
                                  hintText: widget.textFieldHintText,
                                  key: inputextField,
                                )
                        ],
                      ),
                    );
                  },
                ),
              ));
        });
  }
}
