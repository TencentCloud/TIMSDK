import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tuple/tuple.dart';

class TIMUIKitHistoryMessageListTongueContainer extends StatefulWidget {
  final Widget Function(void Function(), MessageListTongueType, int)?
      tongueItemBuilder;
  final List<V2TimGroupAtInfo?>? groupAtInfoList;
  final Function(String targetSeq) scrollToIndexBySeq;
  final AutoScrollController scrollController;
  final TUIChatSeparateViewModel model;

  const TIMUIKitHistoryMessageListTongueContainer(
      {Key? key,
      this.tongueItemBuilder,
      this.groupAtInfoList,
      required this.scrollToIndexBySeq,
      required this.scrollController,
      required this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TIMUIKitHistoryMessageListTongueContainerState();
}

class _TIMUIKitHistoryMessageListTongueContainerState
    extends TIMUIKitState<TIMUIKitHistoryMessageListTongueContainer> {
  bool isFinishJumpToAt = false;
  List<V2TimGroupAtInfo?>? groupAtInfoList = [];
  final TUIChatGlobalModel globalModel = serviceLocator<TUIChatGlobalModel>();

  @override
  void initState() {
    super.initState();
    initScrollListener();
    groupAtInfoList = widget.groupAtInfoList?.reversed.toList();
  }

  void changePositionState(HistoryMessagePosition newPosition) {
    if (globalModel.getMessageListPosition(widget.model.conversationID) !=
        newPosition) {
      globalModel.setMessageListPosition(
          widget.model.conversationID, newPosition);
    }
  }

  scrollHandler() {
    final screenHeight = MediaQuery.of(context).size.height;
    if (widget.scrollController.offset == 0.0 &&
        widget.model.getTempMessageList().isNotEmpty) {
      final double originalHeight =
          widget.scrollController.position.extentAfter;
      widget.model.showLatestUnread();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (widget.scrollController.position.maxScrollExtent > originalHeight) {
          final animateToPosition =
              widget.scrollController.position.maxScrollExtent - originalHeight;
          widget.scrollController.jumpTo(animateToPosition);
        }
      });
    }
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
  }

  void initScrollListener() {
    widget.scrollController.addListener(scrollHandler);
  }

  MessageListTongueType _getTongueValueType(
      List<V2TimGroupAtInfo?>? groupAtInfoList) {
    if (groupAtInfoList != null &&
        groupAtInfoList.isNotEmpty &&
        !isFinishJumpToAt) {
      if (groupAtInfoList[0]!.atType == 1) {
        return MessageListTongueType.atMe;
      } else {
        return MessageListTongueType.atAll;
      }
    }

    if (globalModel.unreadCountForConversation > 0) {
      return MessageListTongueType.showUnread;
    }

    if (globalModel.getMessageListPosition(widget.model.conversationID) ==
        HistoryMessagePosition.awayTwoScreen) {
      return MessageListTongueType.toLatest;
    }

    return MessageListTongueType.none;
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(scrollHandler);
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return Selector<TUIChatGlobalModel, Tuple2<HistoryMessagePosition, int>>(
      builder: (context, value, child) {
        return Positioned(
          bottom: 16,
          right: 16,
          child: TIMUIKitHistoryMessageListTongue(
            tongueItemBuilder: widget.tongueItemBuilder,
            unreadCount: globalModel.unreadCountForConversation,
            onClick: () {
              if (groupAtInfoList != null && groupAtInfoList!.isNotEmpty) {
                if (groupAtInfoList?.length == 1) {
                  widget.scrollToIndexBySeq(groupAtInfoList![0]!.seq);
                  widget.model.markMessageAsRead();
                  setState(() {
                    groupAtInfoList = [];
                    isFinishJumpToAt = true;
                  });
                } else {
                  widget.scrollToIndexBySeq(groupAtInfoList!.removeAt(0)!.seq);
                }
              }
              if (value.item1 == HistoryMessagePosition.awayTwoScreen ||
                  globalModel.unreadCountForConversation > 0) {
                widget.model.showLatestUnread();
                widget.scrollController.animateTo(
                  widget.scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
                return;
              }
            },
            atNum: groupAtInfoList?.length.toString() ?? "",
            valueType: _getTongueValueType(groupAtInfoList),
          ),
        );
      },
      selector: (c, model) {
        final mesageListPosition =
            model.getMessageListPosition(widget.model.conversationID);
        final unreadCountForConversation = model.unreadCountForConversation;
        return Tuple2(mesageListPosition, unreadCountForConversation);
      },
    );
  }
}
