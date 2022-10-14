import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
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

  /// the builder for avatar
  final Widget Function(BuildContext context, V2TimMessage message)? userAvatarBuilder;

  /// the builder for tongue
  final TongueItemBuilder? tongueItemBuilder;

  final Widget? Function(V2TimMessage message, Function() closeTooltip,
      [Key? key, BuildContext? context])? extraTipsActionItemBuilder;

  /// conversation type
  final ConvType conversationType;

  final void Function(String userID)? onTapAvatar;

  @Deprecated(
      "Nickname will not show in one-to-one chat, if you tend to control it in group chat, please use `isShowSelfNameInGroup` and `isShowOthersNameInGroup` from `config: TIMUIKitChatConfig` instead")
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
      this.userAvatarBuilder,
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
  late TIMUIKitHistoryMessageListController _historyMessageListController;

  List<V2TimMessage?> historyMessageList = [];

  Future<void> requestForData(String? lastMsgID, TUIChatSeparateViewModel model,
      [int? count]) async {
    if (model.haveMoreData) {
      await model.loadData(
          count: count ?? (kIsWeb ? 15 : HistoryMessageDartConstant.getCount),
          lastMsgID: lastMsgID);
    }
  }

  Widget Function(BuildContext, V2TimMessage)? _getTopRowBuilder(
      TUIChatSeparateViewModel model) {
    if (widget.messageItemBuilder?.messageNickNameBuilder != null) {
      return (BuildContext context, V2TimMessage message) {
        return widget.messageItemBuilder!.messageNickNameBuilder!(
            context, message, model);
      };
    }
    return null;
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
    final TUIChatSeparateViewModel model =
        Provider.of<TUIChatSeparateViewModel>(context, listen: false);

    return TIMUIKitHistoryMessageListSelector(
      conversationID: model.conversationID,
      builder: (context, messageList, child) {
        return TIMUIKitHistoryMessageList(
          model: model,
          controller: _historyMessageListController,
          groupAtInfoList: widget.groupAtInfoList,
          mainHistoryListConfig: widget.mainHistoryListConfig,
          itemBuilder: (context, message) {
            return TIMUIKitHistoryMessageListItem(
                userAvatarBuilder: widget.userAvatarBuilder,
                topRowBuilder: _getTopRowBuilder(model),
                onScrollToIndex: _historyMessageListController.scrollToIndex,
                onScrollToIndexBegin:
                    _historyMessageListController.scrollToIndexBegin,
                toolTipsConfig: widget.toolTipsConfig ??
                    ToolTipsConfig(
                        additionalItemBuilder:
                            widget.extraTipsActionItemBuilder),
                message: message!,
                onTapForOthersPortrait: widget.onTapAvatar,
                messageItemBuilder: widget.messageItemBuilder,
                onLongPressForOthersHeadPortrait:
                    widget.onLongPressForOthersHeadPortrait,
                allowAtUserWhenReply: chatConfig.isAtWhenReply,
                allowAvatarTap: chatConfig.isAllowClickAvatar,
                allowLongPress: chatConfig.isAllowLongPressMessage,
                isUseMessageReaction: chatConfig.isUseMessageReaction);
          },
          tongueItemBuilder: widget.tongueItemBuilder,
          initFindingMsg: widget.initFindingMsg,
          messageList: messageList,
          onLoadMore: (String? a, [int? b]) async {
            return await requestForData(a, model, b);
          },
        );
      },
    );
  }
}
