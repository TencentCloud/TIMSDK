import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_config.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

enum LoadingPlace {
  none,
  top,
  bottom,
}

class TIMUIKitHistoryMessageListContainer extends StatefulWidget {
  final Widget Function(BuildContext, V2TimMessage?)? itemBuilder;
  final AutoScrollController? scrollController;
  final String conversationID;
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;
  final List<V2TimGroupAtInfo?>? groupAtInfoList;
  final V2TimMessage? initFindingMsg;

  /// message item builder, works for customize all message types and row layout.
  final MessageItemBuilder? messageItemBuilder;

  /// the builder for tongue
  final TongueItemBuilder? tongueItemBuilder;

  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key])? extraTipsActionItemBuilder;

  /// conversation type
  final int conversationType;

  final void Function(String userID)? onTapAvatar;

  @Deprecated("Nickname will not show in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
  final bool showNickName;

  final TIMUIKitHistoryMessageListConfig? mainHistoryListConfig;

  /// tool tips panel configuration, long press message will show tool tips panel
  final ToolTipsConfig? toolTipsConfig;

  const TIMUIKitHistoryMessageListContainer(
      {Key? key,
      this.itemBuilder,
      this.scrollController,
      required this.conversationID,
      required this.conversationType,
      this.onLongPressForOthersHeadPortrait,
      this.groupAtInfoList,
      this.messageItemBuilder,
      this.tongueItemBuilder,
      this.extraTipsActionItemBuilder,
      this.onTapAvatar,
      @Deprecated("Nickname will not show in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
      this.showNickName = true,
      this.initFindingMsg,
      this.mainHistoryListConfig,
      this.toolTipsConfig})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      _TIMUIKitHistoryMessageListContainerState();
}

class _TIMUIKitHistoryMessageListContainerState
    extends TIMUIKitState<TIMUIKitHistoryMessageListContainer> {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  late TIMUIKitHistoryMessageListController _historyMessageListController;

  List<V2TimMessage?> historyMessageList = [];

  Future<void> requestForData(String? lastMsgID, [int? count]) async {
    final convID = widget.conversationID;
    final convType = widget.conversationType;
    if (model.haveMoreData) {
      await model.loadData(
          count: count ?? HistoryMessageDartConstant.getCount, //20
          userID: convType == 1 ? convID : null,
          groupID: convType == 2 ? convID : null,
          lastMsgID: lastMsgID);
    }
  }

  @override
  void initState() {
    super.initState();
    _historyMessageListController = TIMUIKitHistoryMessageListController(
        scrollController: widget.scrollController);
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final chatConfig = Provider.of<TIMUIKitChatConfig>(context);
    return TIMUIKitHistoryMessageListSelector(
      builder: (context, messageList, child) {
        historyMessageList = messageList;
        return TIMUIKitHistoryMessageList(
          controller: _historyMessageListController,
          groupAtInfoList: widget.groupAtInfoList,
          mainHistoryListConfig: widget.mainHistoryListConfig,
          itemBuilder: (context, message) {
            return TIMUIKitHistoryMessageListItem(
              onScrollToIndex: _historyMessageListController.scrollToIndex,
              onScrollToIndexBegin:
                  _historyMessageListController.scrollToIndexBegin,
              toolTipsConfig: widget.toolTipsConfig ??
                  ToolTipsConfig(
                      additionalItemBuilder: widget.extraTipsActionItemBuilder),
              message: message!,
              onTapForOthersPortrait: widget.onTapAvatar,
              messageItemBuilder: widget.messageItemBuilder,
              onLongPressForOthersHeadPortrait:
                  widget.onLongPressForOthersHeadPortrait,
              allowAtUserWhenReply: chatConfig.isAtWhenReply,
              allowAvatarTap: chatConfig.isAllowClickAvatar,
              allowLongPress: chatConfig.isAllowLongPressMessage,
              isUseMessageReaction: chatConfig.isUseMessageReaction
            );
          },
          tongueItemBuilder: widget.tongueItemBuilder,
          initFindingMsg: widget.initFindingMsg,
          messageList: messageList,
          onLoadMore: requestForData,
        );
      },
      conversationID: widget.conversationID,
    );
  }
}
