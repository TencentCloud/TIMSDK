import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
import 'package:tim_ui_kit/ui/widgets/keepalive_wrapper.dart';

class TIMUIKitHistoryMessageList extends StatelessWidget {
  static String? loadMoreTag = "";
  final List<V2TimMessage?> messageList;
  final ValueChanged<String?> loadMore;
  final ScrollController scrollController;
  final bool isNoMoreMessage;
  final void Function(String userID)? onTapAvatar;
  final bool isShowNickName;

  final int conversationType;

  /// 消息构造器
  final Widget? Function(V2TimMessage message)? messageItemBuilder;

  final Widget Function(V2TimMessage message, SuperTooltip? tooltip)?
      exteraTipsActionItemBuilder;

  const TIMUIKitHistoryMessageList(
      {Key? key,
      this.onTapAvatar,
      required this.isNoMoreMessage,
      required this.messageList,
      required this.loadMore,
      required this.scrollController,
      required this.isShowNickName,
      required this.conversationType,
      this.messageItemBuilder,
      this.exteraTipsActionItemBuilder})
      : super(key: key);

  _getMessageId(int index) {
    if (messageList[index]!.elemType == 11) {
      return _getMessageId(index - 1);
    }
    return messageList[index]!.msgID;
  }

  @override
  Widget build(BuildContext context) {
    if (messageList.isEmpty) {
      return Container();
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
          controller: scrollController,
          itemBuilder: (context, index) {
            final messageItem = messageList[index];
            if (index == messageList.length - 1) {
              if (!isNoMoreMessage) {
                final msgID = _getMessageId(index);
                loadMore(msgID);
              }
            }

            return KeepAliveWrapper(
                child: TIMUIKitHistoryMessageListItem(
              exteraTipsActionItemBuilder: exteraTipsActionItemBuilder,
              messageItem: messageItem!,
              onTapAvatar: onTapAvatar,
              isShowNickName: isShowNickName,
              messageItemBuilder: messageItemBuilder,
              conversationType: conversationType,
            ));
          }),
    );
  }
}
