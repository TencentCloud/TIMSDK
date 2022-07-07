import 'package:flutter/cupertino.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';

class TIMUIKitHistoryMessageListTongueContainer extends StatefulWidget {
  final Widget Function(void Function(), MessageListTongueType, int)?
      tongueItemBuilder;
  final List<V2TimGroupAtInfo?>? groupAtInfoList;
  final Function(String targetSeq) scrollToIndexBySeq;
  final AutoScrollController scrollController;

  const TIMUIKitHistoryMessageListTongueContainer(
      {Key? key,
      this.tongueItemBuilder,
      this.groupAtInfoList,
      required this.scrollToIndexBySeq,
      required this.scrollController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TIMUIKitHistoryMessageListTongueContainerState();
}

class _TIMUIKitHistoryMessageListTongueContainerState
    extends TIMUIKitState<TIMUIKitHistoryMessageListTongueContainer> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  bool isFinishJumpToAt = false;
  List<V2TimGroupAtInfo?>? groupAtInfoList = [];

  @override
  void initState() {
    super.initState();
    initScrollListener();
    groupAtInfoList = widget.groupAtInfoList?.reversed.toList();
  }

  void initScrollListener() {
    void changePositionState(HistoryMessagePosition newPosition) {
      if (model.listPosition != newPosition) {
        model.listPosition = newPosition;
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

    if (model.unreadCountForConversation > 0) {
      return MessageListTongueType.showUnread;
    }

    if (model.listPosition == HistoryMessagePosition.awayTwoScreen) {
      return MessageListTongueType.toLatest;
    }

    return MessageListTongueType.none;
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return Positioned(
      bottom: 16,
      right: 0,
      child: TIMUIKitHistoryMessageListTongue(
        tongueItemBuilder: widget.tongueItemBuilder,
        unreadCount: model.unreadCountForConversation,
        onClick: () {
          if (groupAtInfoList != null && groupAtInfoList!.isNotEmpty) {
            if (groupAtInfoList?.length == 1) {
              widget.scrollToIndexBySeq(groupAtInfoList![0]!.seq);
              model.markMessageAsRead(
                  convID: model.currentSelectedConv,
                  convType: model.currentSelectedConvType!);
              setState(() {
                groupAtInfoList = [];
                isFinishJumpToAt = true;
              });
            } else {
              widget.scrollToIndexBySeq(groupAtInfoList!.removeAt(0)!.seq);
            }
          }
          if (model.listPosition == HistoryMessagePosition.awayTwoScreen ||
              model.unreadCountForConversation > 0) {
            model.showLatestUnread(model.currentSelectedConv);
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
  }
}
