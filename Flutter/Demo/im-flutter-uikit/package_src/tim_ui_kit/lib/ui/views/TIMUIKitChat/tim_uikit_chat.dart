import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_text_field.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_multi_select_panel.dart';

import '../../../i18n/i18n_utils.dart';

GlobalKey<dynamic> inputextField = GlobalKey();

class SharedThemeWidget extends InheritedWidget {
  final TUITheme theme;

  const SharedThemeWidget(
      {Key? key, required Widget child, required this.theme})
      : super(key: key, child: child);

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static SharedThemeWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SharedThemeWidget>();
  }

  @override
  bool updateShouldNotify(covariant SharedThemeWidget oldWidget) {
    return oldWidget.theme != theme;
  }
}

class TIMUIKitChat extends StatefulWidget {
  /// conversation id, use for get history message list.
  final String conversationID;

  /// converastion type
  final int conversationType;

  final List<Widget>? appBarActions;

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

  final Widget Function(V2TimMessage message, SuperTooltip? tooltip)?
      exteraTipsActionItemBuilder;

  const TIMUIKitChat(
      {Key? key,
      required this.conversationID,
      required this.conversationType,
      this.onTapAvatar,
      this.showNickName = true,
      this.showTotalUnReadCount = false,
      required this.conversationShowName,
      this.appBarActions,
      this.messageItemBuilder,
      this.exteraTipsActionItemBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TUIChatState();
}

class _TUIChatState extends State<TIMUIKitChat> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final ScrollController listViewScrollContoler = ScrollController();
  bool closeKeyboardPanel = false;

  @override
  void initState() {
    retriveData(null);
    model.markMessageAsRead(
        convID: widget.conversationID, convType: widget.conversationType);
    super.initState();
  }

  void retriveData(String? lastMsgID) {
    final convID = widget.conversationID;
    final convType = widget.conversationType;
    model.loadData(
        count: HistoryMessageDartConstant.getCount, //20
        userID: convType == 1 ? convID : null,
        groupID: convType == 2 ? convID : null,
        lastMsgID: lastMsgID);
  }

  String _getTotalUnReadCount(int unreadCount) {
    return unreadCount < 99 ? unreadCount.toString() : "99";
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
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
                      appBar: AppBar(
                        // automaticallyImplyLeading: false,
                        shadowColor: theme.weakBackgroundColor,
                        backgroundColor: theme.lightPrimaryColor,
                        iconTheme: const IconThemeData(
                          color: Colors.black,
                          size: 24,
                        ),
                        title: Text(
                          widget.conversationShowName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        centerTitle: true,
                        leadingWidth: 100,
                        leading: model.isMultiSelect
                            ? TextButton(
                                onPressed: () {
                                  model.updateMultiSelectStatus(false);
                                },
                                child: const Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  IconButton(
                                    padding: const EdgeInsets.only(left: 8),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      model.setRepliedMessage(null);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  if (widget.showTotalUnReadCount &&
                                      value.totalUnReadCount > 0)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.cautionColor,
                                      ),
                                      child: Text(_getTotalUnReadCount(
                                          value.totalUnReadCount)),
                                    ),
                                ],
                              ),
                        actions: widget.appBarActions,
                      ),
                      body: Column(
                        children: [
                          Expanded(
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Listener(
                                    onPointerMove: OptimizeUtils.throttle(
                                        () => inputextField.currentState
                                            .hideAllPanel(),
                                        60),
                                    child: TIMUIKitHistoryMessageList(
                                      exteraTipsActionItemBuilder:
                                          widget.exteraTipsActionItemBuilder,
                                      conversationType: widget.conversationType,
                                      messageList: model.getMessageListByConvId(
                                              widget.conversationID) ??
                                          [],
                                      loadMore: retriveData,
                                      scrollController: listViewScrollContoler,
                                      isNoMoreMessage: !model.haveMoreData,
                                      onTapAvatar: widget.onTapAvatar,
                                      isShowNickName: widget.showNickName,
                                      messageItemBuilder:
                                          widget.messageItemBuilder,
                                    ),
                                  ))),
                          model.isMultiSelect
                              ? MultiSelectPanel(
                                  conversationShowName:
                                      widget.conversationShowName,
                                  conversationType: widget.conversationType,
                                )
                              : InputTextField(
                                  conversationID: widget.conversationID,
                                  conversationType: widget.conversationType,
                                  listViewController: listViewScrollContoler,
                                  closeKeyboardPanel: closeKeyboardPanel,
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
