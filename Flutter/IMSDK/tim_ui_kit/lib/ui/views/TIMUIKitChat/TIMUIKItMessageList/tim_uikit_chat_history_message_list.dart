// ignore_for_file: unused_import

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_custom_elem.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_location_elem.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tim_ui_kit/ui/widgets/keepalive_wrapper.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

import 'package:tim_ui_kit/data_services/services_locatar.dart';

enum LoadingPlace {
  none,
  top,
  bottom,
}

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
  final V2TimMessage? initFindingMsg;
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;
  final Function(V2TimMessage message)? onMsgSendFailIconTap;
  final ValueChanged<String> updateMsgID;
  final String convId;
  final List<V2TimGroupAtInfo?>? groupAtInfoList;

  /// main history list config
  final ListView? mainHistoryListConfig;

  /// message item builder, works for customize all message types and row layout.
  final MessageItemBuilder? messageItemBuilder;

  /// the builder for tongue
  final TongueItemBuilder? tongueItemBuilder;

  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? exteraTipsActionItemBuilder;

  const TIMUIKitHistoryMessageList({
    Key? key,
    this.onTapAvatar,
    required this.isNoMoreMessage,
    required this.messageList,
    required this.loadMore,
    required this.scrollController,
    required this.isShowNickName,
    required this.conversationType,
    required this.updateMsgID,
    this.messageItemBuilder,
    this.initFindingMsg,
    this.exteraTipsActionItemBuilder,
    this.onLongPressForOthersHeadPortrait,
    this.onMsgSendFailIconTap,
    required this.loadMoreAsync,
    required this.convId,
    this.tongueItemBuilder,
    this.groupAtInfoList,
    this.mainHistoryListConfig,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitHistoryMessageListState();
}

class TIMUIKitHistoryMessageListState
    extends State<TIMUIKitHistoryMessageList> {
  V2TimMessage? findingMsg;
  String findingSeq = "";
  bool isFinishJumpToAt = false;
  LoadingPlace loadingPlace = LoadingPlace.none;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  @override
  initState() {
    super.initState();
    initFinding();
    initScrollListener();
  }

  initFinding() async {
    if (widget.initFindingMsg != null) {
      await widget.loadMoreAsync(null);
      setState(() {
        findingMsg = widget.initFindingMsg!;
      });
    }
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
        widget.scrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.middle,
        );
        widget.scrollController.scrollToIndex(targetIndex,
            preferPosition: AutoScrollPosition.middle);
        // execute twice for accurate position, as the position located firstly can be wrong
        widget.updateMsgID(targetMsg.msgID!);
        setState(() {
          loadingPlace = LoadingPlace.none;
        });
      } else {
        showCantFindMsg();
      }
    } else {
      if (!widget.isNoMoreMessage) {
        // if the target message not in current message list, load more
        setState(() {
          findingMsg = targetMsg;
        });
        widget.loadMore(
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
          findingMsg = null;
        });
        widget.scrollController.scrollToIndex(
          targetIndex,
          preferPosition: AutoScrollPosition.middle,
        );
        widget.scrollController.scrollToIndex(targetIndex,
            preferPosition: AutoScrollPosition.middle);
        if (targetMsgID != null && targetMsgID != "") {
          widget.updateMsgID(targetMsgID);
        }
        setState(() {
          loadingPlace = LoadingPlace.none;
        });
      } else {
        showCantFindMsg();
      }
    } else {
      if (!widget.isNoMoreMessage) {
        setState(() {
          findingSeq = targetSeq;
        });
        widget.loadMore(
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
        setState(() {
          findingMsg = null;
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

  MessageListTongueType _getTongueValueType(
      List<V2TimGroupAtInfo?>? groupAtInfoList) {
    if (groupAtInfoList != null &&
        groupAtInfoList.isNotEmpty &&
        !isFinishJumpToAt) {
      for (V2TimGroupAtInfo? item in groupAtInfoList) {
        if (item!.atType == 1) {
          return MessageListTongueType.atMe;
        } else {
          return MessageListTongueType.atAll;
        }
      }
    }

    if (model.unreadCountForConversation > 0) {
      return MessageListTongueType.showUnread;
    }

    if (model.listPosition == HistoryMessagePosition.awayTwoScreen) {
      return MessageListTongueType.toLatest;
    }

    return MessageListTongueType.none;
  }

  void initScrollListener() {
    void changePositionState(HistoryMessagePosition newPosition) {
      if (model.listPosition != newPosition) {
        setState(() {
          model.listPosition = newPosition;
        });
      }
    }

    widget.scrollController.addListener(() {
      final screenHeight = MediaQuery.of(context).size.height;
      if (widget.scrollController.offset <=
              widget.scrollController.position.minScrollExtent &&
          !widget.scrollController.position.outOfRange) {
        changePositionState(HistoryMessagePosition.bottom);
      } else if (widget.scrollController.offset <= screenHeight * 1.6 &&
          widget.scrollController.offset > 0 &&
          !widget.scrollController.position.outOfRange) {
        changePositionState(HistoryMessagePosition.inTwoScreen);
      } else if (widget.scrollController.offset > screenHeight * 1.6 &&
          !widget.scrollController.position.outOfRange) {
        changePositionState(HistoryMessagePosition.awayTwoScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    List messageList = _filterMessageList(widget.messageList);
    if (widget.messageList.isEmpty) {
      return Container();
    }
    final throteFunction = OptimizeUtils.throttle((index) {
      final msgID = _getMessageId(index);
      widget.loadMore(msgID);
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
                addAutomaticKeepAlives: true,
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
                    key: ValueKey(messageItem.seq),
                    highlightColor: Colors.black.withOpacity(0.1),
                    child: KeepAliveWrapper(
                        child: TIMUIKitHistoryMessageListItem(
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
          ),
          Positioned(
            bottom: 16,
            right: 0,
            child: TIMUIKitHistoryMessageListTongue(
              tongueItemBuilder: widget.tongueItemBuilder,
              unreadCount: model.unreadCountForConversation,
              onClick: () {
                if (widget.groupAtInfoList != null &&
                    widget.groupAtInfoList!.isNotEmpty) {
                  for (V2TimGroupAtInfo? item in widget.groupAtInfoList!) {
                    _onScrollToIndexBySeq(item!.seq);
                    model.markMessageAsRead(
                        convID: widget.convId,
                        convType: widget.conversationType);
                    setState(() {
                      isFinishJumpToAt = true;
                    });
                    return;
                  }
                }

                if (model.listPosition ==
                        HistoryMessagePosition.awayTwoScreen ||
                    model.unreadCountForConversation > 0) {
                  model.showLatestUnread(widget.convId);
                  widget.scrollController.animateTo(
                    widget.scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                  widget.scrollController.animateTo(
                    widget.scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  );
                  return;
                }
              },
              valueType: _getTongueValueType(widget.groupAtInfoList),
            ),
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
