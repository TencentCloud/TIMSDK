import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/utils.dart';
import 'package:tim_ui_kit/ui/widgets/keepalive_wrapper.dart';

import 'TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue_container.dart';

enum LoadingPlace {
  none,
  top,
  bottom,
}

enum ScrollType { toIndex, toIndexBegin }

class TIMUIKitHistoryMessageListController extends ChangeNotifier {
  AutoScrollController? scrollController = AutoScrollController();
  late ScrollType scrollType;
  late V2TimMessage targetMessage;

  TIMUIKitHistoryMessageListController({
    AutoScrollController? scrollController,
  }) {
    if (scrollController != null) {
      this.scrollController = scrollController;
    }
  }

  scrollToIndex(V2TimMessage message) {
    scrollType = ScrollType.toIndex;
    targetMessage = message;
    notifyListeners();
  }

  scrollToIndexBegin(V2TimMessage message) {
    scrollType = ScrollType.toIndexBegin;
    targetMessage = message;
    notifyListeners();
  }
}

class TIMUIKitHistoryMessageList extends StatefulWidget {
  /// message list
  final List<V2TimMessage?> messageList;

  /// tongue item builder
  final TongueItemBuilder? tongueItemBuilder;

  /// group at info, it can get from conversation info
  final List<V2TimGroupAtInfo?>? groupAtInfoList;

  /// use for build message item
  final Widget Function(BuildContext, V2TimMessage?)? itemBuilder;

  /// can controll message list scroll
  final TIMUIKitHistoryMessageListController? controller;

  /// use for message jump, if passed will jump to target message.
  final V2TimMessage? initFindingMsg;

  /// use for load more message
  final Function(String?, [int?]) onLoadMore;

  /// configuration for list view
  final ListView? mainHistoryListConfig;

  const TIMUIKitHistoryMessageList(
      {Key? key,
      required this.messageList,
      this.itemBuilder,
      this.controller,
      required this.onLoadMore,
      this.tongueItemBuilder,
      this.groupAtInfoList,
      this.initFindingMsg,
      this.mainHistoryListConfig})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitHistoryMessageListState();
}

class _TIMUIKitHistoryMessageListState
    extends State<TIMUIKitHistoryMessageList> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  LoadingPlace loadingPlace = LoadingPlace.none;
  V2TimMessage? findingMsg;
  String findingSeq = "";
  late TIMUIKitHistoryMessageListController _controller;
  late AutoScrollController _autoScrollController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TIMUIKitHistoryMessageListController();
    _autoScrollController =
        _controller.scrollController ?? AutoScrollController();
    _controller.addListener(_controllerListener);
    initFinding();
  }

  initFinding() async {
    if (widget.initFindingMsg != null) {
      await widget.onLoadMore(null);
      setState(() {
        findingMsg = widget.initFindingMsg!;
      });
    }
  }

  _controllerListener() {
    final scrollType = _controller.scrollType;
    final targetMessage = _controller.targetMessage;
    switch (scrollType) {
      case ScrollType.toIndex:
        _onScrollToIndex(targetMessage);
        break;
      case ScrollType.toIndexBegin:
        _onScrollToIndexBegin(targetMessage);
        break;
      default:
    }
  }

  Widget _getMessageItemBuilder(V2TimMessage? messageItem) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(context, messageItem);
    }
    return Container();
  }

  _getMessageId(int index) {
    if (widget.messageList[index]!.elemType == 11) {
      return _getMessageId(index - 1);
    }
    return widget.messageList[index]!.msgID;
  }

  _onScrollToIndex(V2TimMessage targetMsg) {
    setState(() {
      if (loadingPlace != LoadingPlace.top) {
        loadingPlace = LoadingPlace.top;
      }
    });
    const int singleLoadAmount = 40;
    final I18nUtils ttBuild = I18nUtils(context);
    final lastTimestamp =
        widget.messageList[widget.messageList.length - 1]?.timestamp;
    final msgList = widget.messageList;
    final targetTimeStamp = targetMsg.timestamp!;

    void showCantFindMsg() {
      setState(() {
        findingMsg = null;
        loadingPlace = LoadingPlace.none;
      });
      Fluttertoast.showToast(
        msg: ttBuild.imt("无法定位到原消息"),
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    }

    if (targetTimeStamp >= lastTimestamp!) {
      // 当前列表里应该有这个消息，试试能不能直接定位到那去
      bool isFound = false;
      int targetIndex = 1;
      for (int i = msgList.length - 1; i >= 0; i--) {
        final currentMsg = msgList[i];
        if (currentMsg?.timestamp == targetTimeStamp &&
            currentMsg?.elemType != 11 &&
            currentMsg!.msgID == targetMsg.msgID) {
          // find the target index by timestamp and msgID
          isFound = true;
          targetIndex = -i;
          break;
        }
      }

      if (isFound && targetIndex != 1) {
        setState(() {
          findingMsg = null;
        });
        _autoScrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.middle,
        );
        _autoScrollController.scrollToIndex(targetIndex,
            preferPosition: AutoScrollPosition.middle);
        // execute twice for accurate position, as the position located firstly can be wrong
        model.jumpMsgID = targetMsg.msgID!;
        setState(() {
          loadingPlace = LoadingPlace.none;
        });
      } else {
        showCantFindMsg();
      }
    } else {
      if (model.haveMoreData) {
        // if the target message not in current message list, load more
        setState(() {
          findingMsg = targetMsg;
        });
        widget.onLoadMore(
            _getMessageId(widget.messageList.length - 1), singleLoadAmount);
      } else {
        showCantFindMsg();
      }
    }
  }

  _onScrollToIndexBySeq(String targetSeq) {
    setState(() {
      if (loadingPlace != LoadingPlace.top) {
        loadingPlace = LoadingPlace.top;
      }
    });
    const int singleLoadAmount = 40;
    final I18nUtils ttBuild = I18nUtils(context);
    final msgList = widget.messageList;
    String lastSeq = "";
    for (int i = msgList.length - 1; i >= 0; i--) {
      final currentMsg = msgList[i];
      if (currentMsg!.seq != null && currentMsg.seq != "") {
        lastSeq = currentMsg.seq!;
        break;
      }
    }

    void showCantFindMsg() {
      setState(() {
        findingSeq = "";
        loadingPlace = LoadingPlace.none;
      });
      Fluttertoast.showToast(
        msg: ttBuild.imt("无法定位到原消息"),
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
    }

    if (int.parse(lastSeq) <= int.parse(targetSeq)) {
      bool isFound = false;
      int targetIndex = 1;
      String? targetMsgID = "";
      for (int i = msgList.length - 1; i >= 0; i--) {
        final currentMsg = msgList[i];
        if (currentMsg?.seq == targetSeq) {
          isFound = true;
          targetMsgID = currentMsg?.msgID;
          targetIndex = -i;
          break;
        }
      }

      if (isFound && targetIndex != 1) {
        setState(() {
          findingSeq = "";
        });
        _autoScrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.middle,
        );
        _autoScrollController.scrollToIndex(targetIndex,
            preferPosition: AutoScrollPosition.middle);
        if (targetMsgID != null && targetMsgID != "") {
          // widget.updateMsgID(targetMsgID);
          model.jumpMsgID = targetMsgID;
        }
        setState(() {
          loadingPlace = LoadingPlace.none;
        });
      } else {
        showCantFindMsg();
      }
    } else {
      if (model.haveMoreData) {
        setState(() {
          findingSeq = targetSeq;
        });
        widget.onLoadMore(
            _getMessageId(widget.messageList.length - 1), singleLoadAmount);
      } else {
        showCantFindMsg();
      }
    }
  }

  _onScrollToIndexBegin(V2TimMessage targetMsg) {
    final lastTimestamp =
        widget.messageList[widget.messageList.length - 1]?.timestamp;
    final msgList = widget.messageList;
    final int targetTimeStamp = targetMsg.timestamp!;

    if (targetTimeStamp >= lastTimestamp!) {
      bool isFound = false;
      int targetIndex = 1;
      for (int i = msgList.length - 1; i >= 0; i--) {
        final currentMsg = msgList[i];
        if (currentMsg?.timestamp == targetTimeStamp &&
            currentMsg?.elemType != 11 &&
            currentMsg!.msgID == targetMsg.msgID) {
          isFound = true;
          targetIndex = -i;
          break;
        }
      }
      if (isFound && targetIndex != 1) {
        _autoScrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.end,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messageList.isEmpty) {
      return Container();
    }
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final messageList = widget.messageList;
    final throteFunction = OptimizeUtils.throttle((index) {
      final msgID =
          TIMUIKitChatUtils.getMessageIDWithinIndex(widget.messageList, index);
      widget.onLoadMore(msgID);
    }, 20);

    if (findingMsg != null) {
      _onScrollToIndex(findingMsg!);
    } else if (findingSeq != "") {
      _onScrollToIndexBySeq(findingSeq);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
                key: widget.mainHistoryListConfig?.key,
                primary: widget.mainHistoryListConfig?.primary,
                physics: widget.mainHistoryListConfig?.physics,
                padding:
                    widget.mainHistoryListConfig?.padding ?? EdgeInsets.zero,
                itemExtent: widget.mainHistoryListConfig?.itemExtent,
                prototypeItem: widget.mainHistoryListConfig?.prototypeItem,
                cacheExtent: widget.mainHistoryListConfig?.cacheExtent ?? 1200,
                semanticChildCount:
                    widget.mainHistoryListConfig?.semanticChildCount,
                dragStartBehavior:
                    widget.mainHistoryListConfig?.dragStartBehavior ??
                        DragStartBehavior.start,
                keyboardDismissBehavior:
                    widget.mainHistoryListConfig?.keyboardDismissBehavior ??
                        ScrollViewKeyboardDismissBehavior.manual,
                restorationId: widget.mainHistoryListConfig?.restorationId,
                clipBehavior:
                    widget.mainHistoryListConfig?.clipBehavior ?? Clip.hardEdge,
                addAutomaticKeepAlives: true,
                reverse: true,
                shrinkWrap: true,
                itemCount: messageList.length,
                controller: _autoScrollController,
                itemBuilder: (context, index) {
                  final messageItem = messageList[index];
                  if (index == messageList.length - 1) {
                    if (model.haveMoreData) {
                      throteFunction(index);
                    }
                  }
                  return AutoScrollTag(
                    controller: _autoScrollController,
                    index: -index,
                    key: ValueKey(-index),
                    highlightColor: Colors.black.withOpacity(0.1),
                    child: KeepAliveWrapper(
                        child: _getMessageItemBuilder(messageItem)),
                  );
                }),
          ),
          TIMUIKitHistoryMessageListTongueContainer(
            scrollController: _autoScrollController,
            scrollToIndexBySeq: _onScrollToIndexBySeq,
            groupAtInfoList: widget.groupAtInfoList,
            tongueItemBuilder: widget.tongueItemBuilder,
          ),
          if (loadingPlace == LoadingPlace.bottom)
            Positioned(
              bottom: 0,
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: theme.weakTextColor ?? Colors.grey,
                size: 28,
              ),
            ),
          if (loadingPlace == LoadingPlace.top)
            Positioned(
              top: 8,
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: theme.weakTextColor ?? Colors.grey,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}

class TIMUIKitHistoryMessageListSelector extends StatelessWidget {
  final Widget Function(BuildContext, List<V2TimMessage?>, Widget?) builder;
  final String conversationID;

  const TIMUIKitHistoryMessageListSelector(
      {Key? key, required this.builder, required this.conversationID})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Selector<TUIChatViewModel, List<V2TimMessage?>>(
        builder: builder,
        selector: (context, model) =>
            model.getMessageListByConvId(conversationID) ?? []);
  }
}
