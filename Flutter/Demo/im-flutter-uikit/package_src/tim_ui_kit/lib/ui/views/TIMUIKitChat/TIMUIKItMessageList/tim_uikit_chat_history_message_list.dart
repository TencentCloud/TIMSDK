import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_custom_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_location_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
import 'package:tim_ui_kit/ui/widgets/keepalive_wrapper.dart';

import '../../../../i18n/i18n_utils.dart';
import '../../../../tim_ui_kit.dart';
import '../TIMUIKitMessageItem/tim_uikit_chat_custom_elem.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TIMUIKitHistoryMessageList extends StatefulWidget {
  static String? loadMoreTag = "";
  final List<V2TimMessage?> messageList;
  final Function(String?, [int?]) loadMore;
  final Function(String?, [int?]) loadMoreAsync;
  final AutoScrollController scrollController;
  final bool isNoMoreMessage;
  final void Function(String userID)? onTapAvatar;
  final bool isShowNickName;
  final int conversationType;
  final int? initFindingTimestamp;
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;
  final Function(V2TimMessage message)? onMsgSendFailIconTap;
  final ValueChanged<int> updateJumpTimestamp;

  /// 消息构造器
  final Widget? Function(V2TimMessage message)? messageItemBuilder;

  /// 位置消息构造器
  final Widget? Function(
    V2TimLocationElem locationElem,
    bool isFromSelf,
    bool isShowJump,
    VoidCallback clearJump,
    String? messageID,
  )? locationMessageItemBuilder;

  final Widget Function(V2TimMessage message, Function() closeTooltip)?
      exteraTipsActionItemBuilder;

  const TIMUIKitHistoryMessageList({
    Key? key,
    this.onTapAvatar,
    required this.isNoMoreMessage,
    required this.messageList,
    required this.loadMore,
    required this.scrollController,
    required this.isShowNickName,
    required this.conversationType,
    required this.updateJumpTimestamp,
    this.messageItemBuilder,
    this.initFindingTimestamp,
    this.exteraTipsActionItemBuilder,
    this.onLongPressForOthersHeadPortrait,
    this.onMsgSendFailIconTap,
    required this.loadMoreAsync,
    this.locationMessageItemBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitHistoryMessageListState();
}

class TIMUIKitHistoryMessageListState
    extends State<TIMUIKitHistoryMessageList> {
  int findingTimestamp = 0;

  @override
  initState() {
    super.initState();
    initFinding();
  }

  initFinding() async {
    if (widget.initFindingTimestamp != null) {
      await widget.loadMoreAsync(null);
      setState(() {
        findingTimestamp = widget.initFindingTimestamp!;
      });
    }
  }

  _getMessageId(int index) {
    if (widget.messageList[index]!.elemType == 11) {
      return _getMessageId(index - 1);
    }
    return widget.messageList[index]!.msgID;
  }

  _onScrollToIndex(int targetTimeStamp, [bool? isRecursion]) {
    const int singleLoadAmount = 40;
    final I18nUtils ttBuild = I18nUtils(context);
    final lastTimestamp =
        widget.messageList[widget.messageList.length - 1]?.timestamp;
    final msgList = widget.messageList;

    void showCantFindMsg() {
      setState(() {
        findingTimestamp = 0;
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
            currentMsg?.elemType != 11) {
          // 通过timestamp找到精准非时间分隔符的目标index
          isFound = true;
          targetIndex = -i;
          break;
        }
      }

      if (isFound && targetIndex != 1) {
        setState(() {
          findingTimestamp = 0;
        });
        widget.scrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.middle,
        );
        widget.scrollController.scrollToIndex(targetIndex,
            preferPosition: AutoScrollPosition.middle);
        // 执行两次是为了修正位置，因为中途有图片重新计算高度会导致第一次停靠位置不准确。
        widget.updateJumpTimestamp(targetTimeStamp);
      } else {
        showCantFindMsg();
      }
    } else {
      if (!widget.isNoMoreMessage) {
        // 当前列表里没有这个消息，需要继续拉取，先定位到最上面
        setState(() {
          findingTimestamp = targetTimeStamp;
        });
        widget.loadMore(
            _getMessageId(widget.messageList.length - 1), singleLoadAmount);
      } else {
        showCantFindMsg();
      }
    }
  }

  _onScrollToIndexBegin(int targetTimeStamp) {
    final lastTimestamp =
        widget.messageList[widget.messageList.length - 1]?.timestamp;
    final msgList = widget.messageList;

    if (targetTimeStamp >= lastTimestamp!) {
      bool isFound = false;
      int targetIndex = 1;
      for (int i = msgList.length - 1; i >= 0; i--) {
        final currentMsg = msgList[i];
        if (currentMsg?.timestamp == targetTimeStamp &&
            currentMsg?.elemType != 11) {
          // 通过timestamp找到精准非时间分隔符的目标index
          isFound = true;
          targetIndex = -i;
          break;
        }
      }
      if (isFound && targetIndex != 1) {
        setState(() {
          findingTimestamp = 0;
        });
        widget.scrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.end,
        );
      }
    }
  }

  _filterCustomMessage(V2TimCustomElem customElem) {
    return false;
  }

  _filterMessageList(List<V2TimMessage?> messageList) {
    if (messageList.isEmpty) {
      return [];
    }

    final newMessageList = [];
    for (var messageItem in messageList) {
      final msgType = messageItem!.elemType;
      bool isFilter = false;
      switch (msgType) {
        case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
          // return Text(ttBuild.imt("[自定义]"));
          isFilter = _filterCustomMessage(
            messageItem.customElem!,
          );
      }

      if (!isFilter) {
        newMessageList.add(messageItem);
      }
    }
    return newMessageList;
  }

  @override
  Widget build(BuildContext context) {
    var messageList = _filterMessageList(widget.messageList);
    if (widget.messageList.isEmpty) {
      return Container();
    }
    final throteFunction = OptimizeUtils.throttle((index) {
      final msgID = _getMessageId(index);
      widget.loadMore(msgID);
    }, 20);
    if (findingTimestamp != 0) {
      _onScrollToIndex(findingTimestamp, true);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
          padding: EdgeInsets.zero,
          addAutomaticKeepAlives: true,
          cacheExtent: 1200,
          reverse: true,
          shrinkWrap: true,
          itemCount: messageList.length,
          controller: widget.scrollController,
          itemBuilder: (context, index) {
            final messageItem = messageList[index];
            if (index == messageList.length - 1) {
              if (!widget.isNoMoreMessage) {
                throteFunction(index);
              }
            }
            return AutoScrollTag(
              controller: widget.scrollController,
              index: -index,
              key: ValueKey(-index),
              highlightColor: Colors.black.withOpacity(0.1),
              child: KeepAliveWrapper(
                  child: TIMUIKitHistoryMessageListItem(
                      locationMessageItemBuilder:
                          widget.locationMessageItemBuilder,
                      scrollToIndex: _onScrollToIndex,
                      scrollToIndexBegin: _onScrollToIndexBegin,
                      exteraTipsActionItemBuilder:
                          widget.exteraTipsActionItemBuilder,
                      messageItem: messageItem!,
                      onTapAvatar: widget.onTapAvatar,
                      isShowNickName: widget.isShowNickName,
                      messageItemBuilder: widget.messageItemBuilder,
                      conversationType: widget.conversationType,
                      onLongPressForOthersHeadPortrait:
                          widget.onLongPressForOthersHeadPortrait,
                      onMsgSendFailIconTap: widget.onMsgSendFailIconTap)),
            );
          }),
    );
  }
}
